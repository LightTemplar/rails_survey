# frozen_string_literal: true

# == Schema Information
#
# Table name: surveys
#
#  id                        :integer          not null, primary key
#  instrument_id             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  uuid                      :string
#  device_id                 :integer
#  instrument_version_number :integer
#  instrument_title          :string
#  device_uuid               :string
#  latitude                  :string
#  longitude                 :string
#  metadata                  :text
#  completion_rate           :string
#  device_label              :string
#  deleted_at                :datetime
#  language                  :string
#  skipped_questions         :text
#  completed_responses_count :integer
#  device_user_id            :integer
#  completed                 :boolean          default(FALSE)
#

require 'sidekiq/api'

class Survey < ApplicationRecord
  include Sanitizer

  scope :ongoing, -> { where(completed: [false, nil]) }
  scope :finished, -> { where(completed: true) }

  belongs_to :instrument
  belongs_to :device
  belongs_to :device_user
  delegate :project, to: :instrument
  has_many :instrument_questions, through: :instrument
  has_many :responses, foreign_key: :survey_uuid, primary_key: :uuid, dependent: :destroy
  has_many :survey_scores, dependent: :destroy
  has_many :survey_notes, foreign_key: :survey_uuid, primary_key: :uuid, dependent: :destroy
  has_one :survey_export, dependent: :destroy

  acts_as_paranoid
  has_paper_trail on: %i[update destroy]

  after_create :calculate_percentage
  after_save :score, if: proc { |survey| survey.completed }
  after_commit :schedule_export, if: proc { |survey| survey.instrument.auto_export_responses }

  validates :uuid, presence: true, allow_blank: false
  validates :instrument_id, presence: true, allow_blank: false

  def title
    "#{id} - #{identifier}"
  end

  def identifier
    questions = Question.where(id: instrument.instrument_questions.pluck(:question_id).uniq)
    question = questions.where(identifies_survey: true).first
    response = responses.where(question_identifier: question.question_identifier).where.not(text: [nil, '']).first if question
    response.nil? || response.text.empty? ? uuid : response.text
  end

  def schedule_export
    job = Sidekiq::ScheduledSet.new.find do |entry|
      entry.item['class'] == 'ExportWorker' && entry.item['args'].first == instrument_id
    end
    return if job

    DateTime.now.hour < 12 ? ExportWorker.perform_at(DateTime.now.at_noon, instrument_id) : ExportWorker.perform_at(DateTime.now.tomorrow.at_noon, instrument_id)
  end

  def switch_instrument(destination_instrument_id)
    destination_instrument = Instrument.find(destination_instrument_id)
    return unless destination_instrument

    saved = update_attributes(instrument_id: destination_instrument.id, instrument_version_number: destination_instrument.current_version_number)
    return unless saved

    responses.each do |response|
      destination_question = destination_instrument.questions.where(question_identifier: "#{response.question_identifier}_#{destination_instrument.project_id}").try(:first)
      next unless destination_question

      response.update_attributes(question_identifier: destination_question.question_identifier, question_id: destination_question.id)
    end
  end

  def calculate_percentage
    job = Sidekiq::ScheduledSet.new.find do |entry|
      entry.item['class'] == 'SurveyPercentWorker' && entry.item['args'].first == id
    end
    SurveyPercentWorker.perform_in(5.hours, id) unless job
  end

  # TODO: Re-implement
  def calculate_completion_rate
    valid_response_count = responses.where.not('text = ? AND other_response = ? AND special_response = ?', nil || '', nil || '', nil || '').pluck(:uuid).uniq.count
    valid_question_count = instrument_questions.count
    rate = (valid_response_count.to_f / valid_question_count.to_f).round(2) if valid_response_count && valid_question_count && valid_question_count != 0
    update_columns(completion_rate: rate.to_s) if rate
  end

  def location
    "#{latitude} / #{longitude}" if latitude && longitude
  end

  delegate :name, to: :project, prefix: true

  delegate :id, to: :project, prefix: true

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
    JSON.parse(read_attribute(:metadata)) if read_attribute(:metadata).present?
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

  def done_on
    timestamp = YAML.safe_load(metadata['location'])['timestamp'] if metadata
    datetime = Time.at(timestamp / 1000).to_datetime if timestamp
    datetime.nil? ? created_at : datetime
  end

  def find_instrument_question(response)
    iq = instrument.instrument_questions.with_deleted.where(id: response.question_id).first
    iq = instrument_question_by_identifier(response.question_identifier) if iq.nil?
    iq
  end

  def instrument_question_by_identifier(question_identifier)
    iq = instrument.instrument_questions.with_deleted.where(identifier: question_identifier).first
    if iq.nil?
      if question_identifier.count('_') > 2
        first = question_identifier.index('_')
        last = question_identifier.rindex('_')
        id = question_identifier[first + 1...last]
        iq = instrument.instrument_questions.with_deleted.where(identifier: id).first
      else
        ids = question_identifier.split('_')
        iq = instrument.instrument_questions.with_deleted.where(identifier: ids[1]).first
      end
    end
    iq
  end

  def option_labels(response)
    iq = find_instrument_question(response)
    vq = iq&.question
    return '' if vq.nil? || !vq.options?

    labels = []
    if Settings.list_question_types.include?(vq.question_type)
      labels << vq.options.map { |o| sanitize o.text }
    else
      response.text.split(Settings.list_delimiter).each do |option_index|
        labels << if vq.question_type == 'CHOICE_TASK'
                    choice_task_labels(vq, option_index.to_i)
                  elsif vq.question_type == 'PAIRWISE_COMPARISON'
                    pairwise_comparison_labels(vq, option_index)
                  elsif vq.other? && option_index.to_i == vq.other_index
                    'Other'
                  else
                    sanitize(label_text(vq, option_index))
                  end
      end
    end
    labels.join(Settings.list_delimiter)
  end

  def choice_task_labels(question, index)
    label = ''
    oios = question.option_set.option_in_option_sets[index]
    oios.option_collages.each do |oc|
      label += ' || ' if label.present?
      oc.collage.diagrams.each do |d|
        label += d.option.identifier
        label += ' & ' unless d == oc.collage.diagrams.last
      end
    end
    "(#{label})"
  end

  def pairwise_comparison_labels(question, index)
    option_identifiers = []
    question.option_in_option_sets.each do |oios|
      oios.option_collages.each do |oc|
        oc.collage.diagrams.each do |d|
          option_identifiers << d.option.identifier
        end
      end
    end
    if index == '1.0'
      "Strongly prefer #{option_identifiers[0]}"
    elsif index == '2.0'
      "Somewhat prefer #{option_identifiers[0]}"
    elsif index == '3.0'
      "No preference between #{option_identifiers[0]} and #{option_identifiers[1]}"
    elsif index == '4.0'
      "Somewhat prefer #{option_identifiers[1]}"
    elsif index == '5.0'
      "Strongly prefer #{option_identifiers[1]}"
    end
  end

  def label_text(versioned_question, option_index)
    versioned_question.options[option_index.to_i].try(:text)
  end

  delegate :sanitize, to: :full_sanitizer

  def start_time
    Rails.cache.fetch("start-time-#{id}-#{updated_at}", expires_in: 30.minutes) do
      responses.where.not(time_started: nil).order('time_started ASC')&.first&.time_started
    end
  end

  def end_time
    Rails.cache.fetch("end-time-#{id}-#{updated_at}", expires_in: 30.minutes) do
      responses.where.not(time_ended: nil).order('time_ended DESC')&.first&.time_ended
    end
  end

  def survey_duration
    end_time - start_time if end_time && start_time
  end

  def question_order
    question_order = []
    s_display_order = metadata['display_order']&.split(',')
    s_display_order ||= instrument.displays.pluck(:title)
    s_display_order.each do |display_title|
      display = instrument.displays.where(title: display_title).first
      question_order << display.instrument_questions.map(&:identifier)
    end
    question_order.flatten!
  end

  def write_wide_row
    headers =
      Rails.cache.fetch("w_w_r_h-#{instrument_id}-#{instrument_version_number}", expires_in: 30.minutes) do
        array = instrument.wide_headers
        array.map.with_index.to_a.to_h
      end
    row = [id, uuid, device.identifier, device_label || device.label, latitude, longitude,
           instrument_id, instrument_version_number, instrument_title, start_time&.to_s, end_time&.to_s, survey_duration]
    metadata&.each do |k, v|
      row[headers[k]] = v
    end
    order = question_order
    responses.each do |response|
      iq = find_instrument_question(response)
      identifier_index = headers["q_#{response.question_identifier}"] unless response.empty?
      row[identifier_index] = response.text if identifier_index
      question_number_index = headers["q_#{response.question_identifier}_number"]
      qid_index = order.index(response.question_identifier)
      row[question_number_index] = (qid_index ? (qid_index + 1) : -1) if question_number_index
      short_qid_index = headers["q_#{response.question_identifier}_short_qid"]
      row[short_qid_index] = response.question_id if short_qid_index
      question_type_index = headers["q_#{response.question_identifier}_question_type"]
      row[question_type_index] = iq&.question&.question_type if question_type_index && iq
      other_text_identifier_index = headers["q_#{response.question_identifier}_other_text"] unless response.empty?
      row[other_text_identifier_index] = response.other_text if other_text_identifier_index
      special_identifier_index = headers["q_#{response.question_identifier}_special"] unless response.empty?
      row[special_identifier_index] = sanitize(response.special_response) if special_identifier_index
      other_identifier_index = headers["q_#{response.question_identifier}_other"] unless response.empty?
      row[other_identifier_index] = response.other_response if other_identifier_index
      label_index = headers["q_#{response.question_identifier}_label"]
      row[label_index] = option_labels(response) if label_index && !response.empty?
      label_order_index = headers["q_#{response.question_identifier}_option_order"]
      row[label_order_index] = response.randomized_data if label_order_index && response.randomized_data.present?
      question_version_index = headers["q_#{response.question_identifier}_version"]
      row[question_version_index] = response.question_version if question_version_index
      question_text_index = headers["q_#{response.question_identifier}_text"]
      row[question_text_index] = sanitize(iq&.question&.text) if question_text_index
      start_time_index = headers["q_#{response.question_identifier}_start_time"]
      row[start_time_index] = response.time_started.to_s if start_time_index
      end_time_index = headers["q_#{response.question_identifier}_end_time"]
      row[end_time_index] = response.time_ended.to_s if end_time_index
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
    row.map! { |item| item || '' }
    survey_export.update(wide: row.to_s, last_response_at: responses.pluck(:updated_at).max)
  end

  def write_long_row
    headers = Rails.cache.fetch("w_l_r_h-#{instrument_id}-#{instrument_version_number}", expires_in: 30.minutes) do
      array = instrument.long_headers
      array.map.with_index.to_a.to_h
    end
    csv = []
    responses.each do |response|
      next if response.empty?

      iq = find_instrument_question(response)
      row = Rails.cache.fetch("w_l_r-#{instrument_id}-#{instrument_version_number}-#{id}-#{updated_at}-#{response.id}
        -#{response.updated_at}", expires_in: 30.minutes) do
        ["q_#{response.question_identifier}", "q_#{response.question_id}", instrument_id,
         response.instrument_version_number, response.question_version, instrument_title, id,
         response.survey_uuid, device_id, device_uuid, device_label, iq&.question&.question_type,
         sanitize(iq&.question&.text), response.text, option_labels(response), response.other_text, sanitize(response.special_response),
         response.other_response, response.time_started.to_s, response.time_ended.to_s, response.device_user.try(:id),
         response.device_user.try(:username), start_time&.to_s, end_time&.to_s, survey_duration]
      end
      metadata&.each do |k, v|
        row[headers[k]] = v if headers[k]
      end
      row.map! { |item| item || '' }
      csv << row
    end
    survey_export.update(long: csv.to_s, last_response_at: responses.pluck(:updated_at).max)
  end

  def score
    instrument.score_schemes.where(active: true).find_each do |scheme|
      ScoreGeneratorWorker.perform_async(scheme.id, id)
    end
  end

  def response_for_question(question)
    responses.where(question_identifier: question.question_identifier).try(:first)
  end

  def skipped
    skipped_questions.split(',')
  end
end
