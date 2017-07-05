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
  delegate :project, to: :instrument
  validates :device_id, presence: true, allow_blank: false
  validates :uuid, presence: true, allow_blank: false
  validates :instrument_id, presence: true, allow_blank: false
  validates :instrument_version_number, presence: true, allow_blank: false
  paginates_per 50
  after_create :calculate_percentage
  scope :non_roster, -> { where(roster_uuid: nil) }
  @sanitizer = Rails::Html::FullSanitizer.new

  def scores
    Score.where('survey_id = ? OR survey_uuid = ?', id, uuid)
  end

  def calculate_percentage
    SurveyPercentWorker.perform_in(5.hours, id)
  end

  def calculate_completion_rate
    valid_response_count = responses.where.not('text = ? AND other_response = ? AND special_response = ?', nil || '', nil || '', nil || '').pluck(:question_id).uniq.count
    valid_question_count = instrument.version_by_version_number(instrument_version_number).questions.select { |question| question.question_type != 'INSTRUCTIONS' }.count
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
    JSON.parse(read_attribute(:metadata)) unless read_attribute(:metadata).nil?
  end

  def center_id
    metadata['Center ID'] if metadata
  end

  def participant_id
    metadata['Participant ID'] if metadata
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

  def self.create_file(instrument, format)
    root = File.join('files', 'exports').to_s
    File.new(root + "/#{Time.now.to_i}_#{instrument.title}_#{format}.csv", 'a+')
  end

  def self.instrument_export(instrument)
    short_csv = create_file(instrument, 'short')
    wide_csv = create_file(instrument, 'wide')
    long_csv = create_file(instrument, 'long')
    long_csv.close
    wide_csv.close
    short_csv.close
    export = ResponseExport.create(instrument_id: instrument.id, instrument_versions: instrument.survey_instrument_versions, short_format_url: short_csv.path, wide_format_url: wide_csv.path, long_format_url: long_csv.path)
    write_short_header(short_csv)
    write_long_header(long_csv, instrument)
    write_wide_header(wide_csv, instrument)
    export_wide_csv(wide_csv, instrument, export.id)
    export_short_csv(short_csv, instrument, export.id)
    export_long_csv(long_csv, instrument, export.id)
    set_export_count(export.id.to_s, instrument.surveys.count * 3)
    StatusWorker.perform_in(5.seconds, export.id)
    export.id
  end

  def self.export_short_csv(short_csv, instrument, export_id)
    instrument.surveys.each do |survey|
      ShortExportWorker.perform_async(short_csv.path, survey.uuid, export_id)
    end
  end

  def self.write_short_header(short_csv)
    CSV.open(short_csv, 'wb') do |csv|
      csv << %w(identifier survey_id question_identifier question_text response_text response_label special_response other_response)
    end
  end

  def self.write_short_row(file, survey_uuid, export_id)
    survey = get_survey(survey_uuid)
    validator = survey.validation_identifier
    CSV.open(file, 'a+') do |csv|
      survey.responses.each do |response|
        csv << [validator, survey.id, response.question_identifier, @sanitizer.sanitize(survey.versioned_question(response.question_identifier).try(:text)), response.text, survey.option_labels(response), response.special_response, response.other_response]
      end
    end
    decrement_export_count(export_id.to_s)
  end

  def validation_identifier
    return unless metadata
    metadata['Center ID'] ? metadata['Center ID'] : metadata['Participant ID']
  end

  def self.export_wide_csv(wide_csv, instrument, export_id)
    instrument.surveys.each do |survey|
      WideExportWorker.perform_async(wide_csv.path, survey.uuid, export_id)
    end
  end

  def self.metadata_keys(ins)
    last_update = ins.surveys.order('updated_at ASC').try(:last).try(:updated_at)
    Rails.cache.fetch("survey-metadata-#{ins.id}-#{last_update}", expires_in: 24.hours) do
      m_keys = []
      ins.surveys.each do |survey|
        next unless survey.metadata
        survey.metadata.keys.each do |key|
          m_keys << key unless m_keys.include? key
        end
      end
      m_keys
    end
  end

  def self.write_wide_header(wide_csv, ins)
    variable_identifiers = []
    question_identifier_variables = %w(_short_qid _question_type _label _special _other _version _text _start_time _end_time)
    ins.questions.each do |question|
      variable_identifiers << question.question_identifier unless variable_identifiers.include? question.question_identifier
      question_identifier_variables.each do |variable|
        variable_identifiers << question.question_identifier + variable unless variable_identifiers.include? question.question_identifier + variable
      end
    end
    header = %w(survey_id survey_uuid device_identifier device_label latitude longitude instrument_id instrument_version_number instrument_title survey_start_time survey_end_time device_user_id device_user_username) + metadata_keys(ins) + variable_identifiers
    CSV.open(wide_csv, 'wb') do |csv|
      csv << header
    end
  end

  def start_time
    Rails.cache.fetch("survey-start-#{id}-#{ordered_response('time_started', 'ASC')}", expires_in: 24.hours) do
      ordered_response('time_started', 'ASC')
    end
  end

  def end_time
    Rails.cache.fetch("survey-end-#{id}-#{ordered_response('time_ended', 'DESC')}", expires_in: 24.hours) do
      ordered_response('time_ended', 'DESC')
    end
  end

  def ordered_response(ord_attr, ord)
    responses.order("#{ord_attr} #{ord}").try(:first).try(ord.to_sym)
  end

  def self.get_survey(survey_uuid)
    key2 = Response.where(survey_uuid: survey_uuid).order('updated_at ASC').last.try(:updated_at)
    Rails.cache.fetch("survey-#{survey_uuid}-#{key2}", expires_in: 24.hours) do
      Survey.includes(:responses).where(uuid: survey_uuid).first
    end
  end

  def self.write_wide_row(file, survey_uuid, export_id)
    survey = get_survey(survey_uuid)
    headers = get_headers(file)
    CSV.open(file, 'a+') do |csv|
      row = [survey.id, survey.uuid, survey.device.identifier, survey.device_label ? survey.device_label : survey.device.label, survey.latitude, survey.longitude, survey.instrument.id, survey.instrument_version_number, survey.instrument.title, survey.start_time, survey.end_time]

      if survey.metadata
        survey.metadata.each do |k, v|
          key_index = headers.index { |h| h == k }
          row[key_index] = v
        end
      end

      survey.responses.each do |response|
        identifier_index = headers.index(response.question_identifier)
        row[identifier_index] = response.text if identifier_index
        short_qid_index = headers.index(response.question_identifier + '_short_qid')
        row[short_qid_index] = response.question_id if short_qid_index
        question_type_index = headers.index(response.question_identifier + '_question_type')
        row[question_type_index] = survey.versioned_question(response.question_identifier).try(:question_type) if question_type_index
        special_identifier_index = headers.index(response.question_identifier + '_special')
        row[special_identifier_index] = response.special_response if special_identifier_index
        other_identifier_index = headers.index(response.question_identifier + '_other')
        row[other_identifier_index] = response.other_response if other_identifier_index
        label_index = headers.index(response.question_identifier + '_label')
        row[label_index] = survey.option_labels(response) if label_index
        question_version_index = headers.index(response.question_identifier + '_version')
        row[question_version_index] = response.question_version if question_version_index
        question_text_index = headers.index(response.question_identifier + '_text')
        row[question_text_index] = @sanitizer.sanitize(survey.versioned_question(response.question_identifier).try(:text)) if question_text_index
        start_time_index = headers.index(response.question_identifier + '_start_time')
        row[start_time_index] = response.time_started if start_time_index
        end_time_index = headers.index(response.question_identifier + '_end_time')
        row[end_time_index] = response.time_ended if end_time_index
      end
      device_user_id_index = headers.index('device_user_id')
      device_user_username_index = headers.index('device_user_username')
      device_user_ids = survey.responses.pluck(:device_user_id).uniq.compact
      unless device_user_ids.empty?
        row[device_user_id_index] = device_user_ids.join(',')
        row[device_user_username_index] = DeviceUser.find(device_user_ids).map(&:username).uniq.join(',')
      end
      csv << row
    end
    decrement_export_count(export_id.to_s)
  end

  def self.get_headers(file)
    @headers ||= Hash.new do |hash, filename|
      hash[filename] = CSV.open(filename, 'r', &:first)
    end
    @headers[file]
  end

  def self.export_long_csv(long_csv, model, export_id)
    model.surveys.each do |survey|
      LongExportWorker.perform_async(long_csv.path, survey.uuid, export_id)
    end
  end

  def self.write_long_header(long_csv, ins)
    header = %w(qid short_qid instrument_id instrument_version_number question_version_number instrument_title survey_id survey_uuid device_id device_uuid device_label question_type question_text response response_labels special_response other_response response_time_started response_time_ended device_user_id device_user_username) + metadata_keys(ins)
    CSV.open(long_csv, 'wb') do |csv|
      csv << header
    end
  end

  def self.write_long_row(file, survey_uuid, export_id)
    survey = get_survey(survey_uuid)
    headers = get_headers(file)
    CSV .open(file, 'a+') do |csv|
      survey.responses.each do |response|
        row = [response.question_identifier, "q_#{response.question_id}", survey.instrument_id, response.instrument_version_number, response.question_version, survey.instrument_title, survey.id, response.survey_uuid, survey.device_id, survey.device_uuid, survey.device_label, survey.versioned_question(response.question_identifier).try(:question_type), @sanitizer.sanitize(survey.versioned_question(response.question_identifier).try(:text)), response.text, survey.option_labels(response), response.special_response, response.other_response, response.time_started, response.time_ended, response.device_user.try(:id), response.device_user.try(:username)]
        if survey.metadata
          survey.metadata.each do |k, v|
            row[headers.index(k)] = v if headers.index(k)
          end
        end
        csv << row
      end
    end
    decrement_export_count(export_id.to_s)
  end

  def score
    scheme = instrument.score_schemes.first
    scheme.score_survey(self)
  end

  def response_for_question(question)
    responses.where(question_identifier: question.question_identifier).try(:first)
  end
end
