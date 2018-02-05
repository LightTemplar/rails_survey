# == Schema Information
#
# Table name: surveys
#
#  id                        :integer          not null, primary key
#  instrument_id             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  uuid                      :string(255)
#  device_id                 :integer
#  instrument_version_number :integer
#  instrument_title          :string(255)
#  device_uuid               :string(255)
#  latitude                  :string(255)
#  longitude                 :string(255)
#  metadata                  :text
#  completion_rate           :string(3)
#  device_label              :string(255)
#  deleted_at                :datetime
#  has_critical_responses    :boolean
#  roster_uuid               :string(255)
#  language                  :string(255)
#  randomization_order       :text
#

class Survey < ActiveRecord::Base
  include RedisJobTracker
  belongs_to :instrument
  belongs_to :device
  belongs_to :roster, foreign_key: :roster_uuid, primary_key: :uuid
  has_many :responses, foreign_key: :survey_uuid, primary_key: :uuid, dependent: :destroy
  has_many :centralized_scores, class_name: 'Score', foreign_key: :survey_id, dependent: :destroy
  has_many :distributed_scores, class_name: 'Score', foreign_key: :survey_uuid, dependent: :destroy
  acts_as_paranoid
  has_paper_trail
  delegate :project, to: :instrument
  validates :device_id, presence: true, allow_blank: false
  validates :uuid, presence: true, allow_blank: false
  validates :instrument_id, presence: true, allow_blank: false
  validates :instrument_version_number, presence: true, allow_blank: false
  paginates_per 50
  after_create :calculate_percentage
  after_commit :schedule_export, if: proc { |survey| survey.instrument.auto_export_responses }
  scope :non_roster, -> { where(roster_uuid: nil) }

  def delete_duplicate_responses
    grouped_responses = responses.group_by {|response| response.uuid}
    grouped_responses.values.each do |duplicates|
      duplicates.shift
      duplicates.map(&:delete)
    end
  end

  def schedule_export
    job = Sidekiq::ScheduledSet.new.find do |entry|
      entry.item['class'] == 'ExportWorker' && entry.item['args'].first == instrument_id
    end
    ExportWorker.perform_at(DateTime.now.end_of_day + 2.hours, instrument_id) unless job
  end

  def switch_instrument(destination_instrument_id)
    destination_instrument = Instrument.find(destination_instrument_id)
    return unless destination_instrument
    saved = update_attributes(instrument_id: destination_instrument.id, instrument_version_number: destination_instrument.current_version_number)
    if saved
      responses.each do |response|
        destination_question = destination_instrument.questions.where(question_identifier: "#{response.question_identifier}_#{destination_instrument.project_id}").try(:first)
        next unless destination_question
        response.update_attributes(question_identifier: destination_question.question_identifier, question_id: destination_question.id)
      end
    end
  end

  def scores
    Score.where('survey_id = ? OR survey_uuid = ?', id, uuid)
  end

  def calculate_percentage
    SurveyPercentWorker.perform_in(5.hours, id)
  end

  def calculate_completion_rate
    valid_response_count = responses.where.not('text = ? AND other_response = ? AND special_response = ?', nil || '', nil || '', nil || '').pluck(:question_id).uniq.count
    valid_question_count = instrument.version_by_version_number(instrument_version_number).questions.reject { |question| question.question_type == 'INSTRUCTIONS' }.count
    if valid_response_count && valid_question_count && valid_question_count != 0
      rate = (valid_response_count.to_f / valid_question_count.to_f).round(2)
    end
    update_columns(completion_rate: rate.to_s) if rate
  end

  def location
    "#{latitude} / #{longitude}" if latitude && longitude
  end

  def group_responses_by_day
    responses.group_by_day(:created_at).count
  end

  def group_responses_by_hour
    responses.group_by_hour_of_day(:created_at).count
  end

  def instrument_version
    instrument.version_by_version_number(instrument_version_number)
  end

  def location_link
    "https://www.google.com/maps/place/#{latitude}+#{longitude}" if latitude && longitude
  end

  def metadata
    JSON.parse(read_attribute(:metadata)) unless read_attribute(:metadata).blank?
  end

  def center_id
    metadata['Center ID'] if metadata
  end

  def participant_id
    metadata['Participant ID'] if metadata
  end

  def caregiver_id
    metadata['Caregiver ID'] if metadata
  end

  def label
    metadata['survey_label'] if metadata
  end

  def randomization_order
    JSON.parse(read_attribute(:randomization_order)) unless read_attribute(:randomization_order).blank?
  end

  def versioned_question(question_identifier)
    instrument_version.find_question_by(question_identifier: question_identifier)
  end

  def option_labels(response)
    vq = versioned_question(response.question_identifier)
    return '' if vq.nil? || !vq.optionable?
    labels = []
    if Settings.list_question_types.include?(vq.question_type)
      labels << vq.non_special_options.map(&:text)
    else
      response.text.split(Settings.list_delimiter).each do |option_index|
        labels << if vq.other? && option_index.to_i == vq.other_index
                    'Other'
                  else
                    label_text(vq, option_index)
                  end
      end
    end
    labels.join(Settings.list_delimiter)
  end

  def label_text(versioned_question, option_index)
    if versioned_question.grid
      versioned_question.grid_labels[option_index.to_i].try(:label)
    else
      versioned_question.non_special_options[option_index.to_i].try(:text)
    end
  end

  def sanitize(str)
    sanitizer = Rails::Html::FullSanitizer.new
    sanitizer.sanitize(str)
  end

  def write_short_row
    validator = validation_identifier
    responses.each do |response|
      csv = Rails.cache.fetch("w_s_r-#{instrument_id}-#{instrument_version_number}-#{id}-#{updated_at}-#{response.id}-#{response.updated_at}", expires_in: 30.minutes) do
        [validator, id, response.question_identifier, sanitize(versioned_question(response.question_identifier).try(:text)), response.text, option_labels(response), response.special_response, response.other_response]
      end
      push_to_redis("short-row-#{id}-#{instrument.response_export.id}-#{response.id}",
        "short-keys-#{instrument.id}-#{instrument.response_export.id}", csv)
    end
    decrement_export_count("#{instrument.response_export.id}_short")
  end

  def validation_identifier
    return unless metadata
    metadata['Center ID'] ? metadata['Center ID'] : metadata['Participant ID']
  end

  def start_time
    responses.where.not(time_started: nil).order('time_started ASC').try(:first).try(:time_started)
  end

  def end_time
    responses.where.not(time_ended: nil).order('time_ended DESC').try(:first).try(:time_ended)
  end

  def write_wide_row
    headers =
      Rails.cache.fetch("w_w_r_h-#{instrument_id}-#{instrument_version_number}", expires_in: 30.minutes) do
        array = instrument.wide_headers
        Hash[array.map.with_index.to_a]
      end
    row = [id, uuid, device.identifier, device_label ? device_label : device.label, latitude, longitude, instrument_id, instrument_version_number, instrument_title, start_time, end_time]

    if metadata
      metadata.each do |k, v|
        row[headers[k]] = v
      end
    end

    responses.each do |response|
      identifier_index = headers[response.question_identifier]
      row[identifier_index] = response.text if identifier_index
      short_qid_index = headers[response.question_identifier + '_short_qid']
      row[short_qid_index] = response.question_id if short_qid_index
      question_type_index = headers[response.question_identifier + '_question_type']
      row[question_type_index] = versioned_question(response.question_identifier).try(:question_type) if question_type_index
      special_identifier_index = headers[response.question_identifier + '_special']
      row[special_identifier_index] = response.special_response if special_identifier_index
      other_identifier_index = headers[response.question_identifier + '_other']
      row[other_identifier_index] = response.other_response if other_identifier_index
      label_index = headers[response.question_identifier + '_label']
      row[label_index] = option_labels(response) if label_index
      question_version_index = headers[response.question_identifier + '_version']
      row[question_version_index] = response.question_version if question_version_index
      question_text_index = headers[response.question_identifier + '_text']
      row[question_text_index] = sanitize(versioned_question(response.question_identifier).try(:text)) if question_text_index
      start_time_index = headers[response.question_identifier + '_start_time']
      row[start_time_index] = response.time_started if start_time_index
      end_time_index = headers[response.question_identifier + '_end_time']
      row[end_time_index] = response.time_ended if end_time_index
      position_index = headers[response.question_identifier + '_position']
      row[position_index] = position_shown(response) if position_index
      if response.randomized_data
        response.randomized_data.each do |k, v|
          unless k.blank?
            qrf = response.question.question_randomized_factors.where(position: k.to_i).first
            ro = RandomizedOption.where(id: v.to_i).first if qrf
            rf_index = headers["#{response.question_identifier}_#{qrf.randomized_factor.title}"] if qrf
            row[rf_index] = ro.text if ro && rf_index
          end
        end
      end
    end
    device_user_id_index = headers['device_user_id']
    device_user_username_index = headers['device_user_username']
    device_user_ids = Rails.cache.fetch("d_u_i-#{id}-#{updated_at}-#{responses.maximum('updated_at')}") do
      responses.pluck(:device_user_id).uniq.compact
    end
    unless device_user_ids.empty?
      row[device_user_id_index] = device_user_ids.join(',')
      row[device_user_username_index] = DeviceUser.find(device_user_ids).map(&:username).uniq.join(',')
    end
    push_to_redis("wide-row-#{id}-#{instrument.response_export.id}-survey-#{id}",
      "wide-keys-#{instrument_id}-#{instrument.response_export.id}", row)
    decrement_export_count("#{instrument.response_export.id}_wide")
  end

  def write_long_row
    headers = Rails.cache.fetch("w_l_r_h-#{instrument_id}-#{instrument_version_number}", expires_in: 30.minutes) do
      array = instrument.long_headers
      Hash[array.map.with_index.to_a]
    end
    responses.each do |response|
      row = Rails.cache.fetch("w_l_r-#{instrument_id}-#{instrument_version_number}-#{id}-#{updated_at}-#{response.id}-#{response.updated_at}", expires_in: 30.minutes) do
        [response.question_identifier, "q_#{response.question_id}", instrument_id,
          response.instrument_version_number, response.question_version, instrument_title,
          id, response.survey_uuid, device_id, device_uuid, device_label,
          versioned_question(response.question_identifier).try(:question_type),
          sanitize(versioned_question(response.question_identifier).try(:text)),
          response.text, option_labels(response), response.special_response,
          response.other_response, response.time_started, response.time_ended,
          response.device_user.try(:id), response.device_user.try(:username),
          position_shown(response)]
      end
      if response.randomized_data
        response.randomized_data.each do |k, v|
          unless k.blank?
            qrf = response.question.question_randomized_factors.where(position: k.to_i).first
            ro = RandomizedOption.where(id: v.to_i).first if qrf
            row[headers[qrf.randomized_factor.title]] = ro.text if ro
          end
        end
      end
      if metadata
        metadata.each do |k, v|
          row[headers[k]] = v if headers[k]
        end
      end
      push_to_redis("long-row-#{id}-#{instrument.response_export.id}-#{response.id}",
        "long-keys-#{instrument_id}-#{instrument.response_export.id}", row)
    end
    decrement_export_count("#{instrument.response_export.id}_long")
  end

  def position_shown(response)
    if randomization_order && randomization_order[response.question_identifier]
      randomization_order[response.question_identifier]
    else
      response.question.number_in_instrument if response.question
    end
  end

  def push_to_redis(key_one, key_two, data)
    $redis.del key_one
    $redis.rpush key_one, data
    $redis.rpush key_two, key_one
  end

  def score
    scheme = instrument.score_schemes.first
    scheme.score_survey(self)
  end

  def response_for_question(question)
    responses.where(question_identifier: question.question_identifier).try(:first)
  end
end
