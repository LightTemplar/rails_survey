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
#

class Survey < ActiveRecord::Base
  include RedisJobTracker
  belongs_to :instrument
  belongs_to :device
  has_many :responses, foreign_key: :survey_uuid, primary_key: :uuid, dependent: :destroy
  delegate :project, to: :instrument
  validates :device_id, presence: true, allow_blank: false
  validates :uuid, presence: true, allow_blank: false
  validates :instrument_id, presence: true, allow_blank: false
  validates :instrument_version_number, presence: true, allow_blank: false
  paginates_per 50
  after_create :calculate_percentage

  def calculate_percentage
    SurveyPercentWorker.perform_in(5.hours, id)
  end

  def calculate_completion_rate
    valid_response_count = responses.where.not('text = ? AND other_response = ? AND special_response = ?',
                                               nil || '', nil || '', nil || '').pluck(:question_id).uniq.count
    valid_question_count = instrument.version_by_version_number(instrument_version_number)
                               .questions.select{|question| question.question_type != 'INSTRUCTIONS'}.count
    rate = (valid_response_count.to_f / valid_question_count.to_f).round(2) if (valid_response_count &&
        valid_question_count && valid_question_count != 0)
    update_columns(completion_rate: rate.to_s) if rate
  end

  def location
    "#{latitude} / #{longitude}" if latitude and longitude
  end

  def group_responses_by_day
    self.responses.group_by_day(:created_at).count
  end

  def group_responses_by_hour
    self.responses.group_by_hour_of_day(:created_at).count
  end

  def instrument_version
    instrument.version_by_version_number(instrument_version_number)
  end

  def location_link
    "https://www.google.com/maps/place/#{latitude}+#{longitude}" if latitude and longitude
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

  def chronicled_question(question_identifier)
    @chronicled_question ||= Hash.new do |question_hash, q_id|
      question_hash[q_id] = instrument_version.find_question_by(question_identifier: q_id)
    end
    @chronicled_question[question_identifier]
  end

  def option_labels(response)
    labels = []
    versioned_question = chronicled_question(response.question_identifier)
    if response.question and versioned_question and versioned_question.has_options?
      response.text.split(Settings.list_delimiter).each do |option_index|
        (versioned_question.has_other? and option_index.to_i == versioned_question.other_index) ? labels << "Other" : labels << versioned_question.options[option_index.to_i].to_s
      end
    end
    labels.join(Settings.list_delimiter)
  end

  def self.instrument_export(instrument)
    root = File.join('files', 'exports').to_s
    short_csv = File.new(root + "/#{Time.now.to_i}_#{instrument.title}_short.csv", 'a+')
    wide_csv = File.new(root + "/#{Time.now.to_i}_#{instrument.title}_wide.csv", 'a+')
    long_csv = File.new(root + "/#{Time.now.to_i}_#{instrument.title}_long.csv", 'a+')
    long_csv.close
    wide_csv.close
    short_csv.close
    export = ResponseExport.create(:instrument_id => instrument.id, :instrument_versions => instrument.survey_instrument_versions,
              :short_format_url => short_csv.path, :wide_format_url => wide_csv.path, :long_format_url => long_csv.path)
    write_short_header(short_csv)
    write_long_header(long_csv, instrument)
    write_wide_header(wide_csv, instrument)
    export_wide_csv(wide_csv, instrument, export.id)
    export_short_csv(short_csv, instrument, export.id)
    export_long_csv(long_csv, instrument, export.id)
    set_export_count(export.id.to_s, instrument.surveys.count * 3)
    StatusWorker.perform_in(5.minutes, export.id)
    export.id
  end

  def self.export_short_csv(short_csv, instrument, export_id)
    interval = 0
    instrument.surveys.each do |survey|
      interval += 10
      ShortExportWorker.perform_in(interval.seconds, short_csv.path, survey.id, export_id)
    end
  end

  def self.write_short_header(short_csv)
    CSV.open(short_csv, 'wb') do |csv|
      csv << %w[identifier survey_id question_identifier question_text response_text response_label special_response other_response]
    end
  end

  def self.write_short_row(file, survey_id, export_id)
    survey = Survey.includes(:responses).where(id: survey_id).first
    validator = survey.validation_identifier
    CSV.open(file, 'a+') do |csv|
      survey.responses.each do |response|
        csv << [validator, survey.id, response.question_identifier, Sanitize.fragment(survey.chronicled_question(response.question_identifier).try(:text)),
                response.text, response.option_labels, response.special_response, response.other_response]
      end
    end
    decrement_export_count(export_id.to_s)
  end

  def validation_identifier
    metadata['Center ID'] ? metadata['Center ID'] : metadata['Participant ID'] if metadata
  end

  def self.export_wide_csv(wide_csv, instrument, export_id)
    interval = 0
    instrument.surveys.each do |survey|
      interval += 10
      WideExportWorker.perform_in(interval.seconds, wide_csv.path, survey.id, export_id)
    end
  end

  def self.write_wide_header(wide_csv, model)
    variable_identifiers = []
    question_identifier_variables = %w[_short_qid _question_type _label _special _other _version _text _start_time _end_time]
    model.questions.each do |question|
      variable_identifiers << question.question_identifier unless variable_identifiers.include? question.question_identifier
      question_identifier_variables.each do |variable|
        variable_identifiers << question.question_identifier + variable unless variable_identifiers.include? question.question_identifier + variable
      end
    end
    metadata_keys = []
    model.surveys.each do |survey|
      survey.metadata.keys.each do |key|
        metadata_keys << key unless metadata_keys.include? key
      end if survey.metadata
    end
    header = %w[survey_id survey_uuid device_identifier device_label latitude longitude instrument_id instrument_version_number
              instrument_title survey_start_time survey_end_time device_user_id device_user_username] + metadata_keys + variable_identifiers
    CSV.open(wide_csv, 'wb') do |csv|
      csv << header
    end
  end

  def self.write_wide_row(file, survey_id, export_id)
    survey = Survey.includes(:responses).where(id: survey_id).first
    headers = get_headers(file)
    CSV.open(file, 'a+') do |csv|
      row = [survey.id, survey.uuid, survey.device.identifier, survey.device_label ? survey.device_label : survey.device.label, survey.latitude, survey.longitude, survey.instrument.id,
             survey.instrument_version_number, survey.instrument.title, survey.responses.order('time_started').try(:first).try(:time_started),
             survey.responses.order('time_ended').try(:last).try(:time_ended)]

      survey.metadata.each do |k, v|
        key_index = headers.index {|h| h == k}
        row[key_index] = v
      end if survey.metadata

      survey.responses.each do |response|
        identifier_index = headers.index(response.question_identifier)
        row[identifier_index] = response.text if identifier_index
        short_qid_index = headers.index(response.question_identifier + '_short_qid')
        row[short_qid_index] = response.question_id if short_qid_index
        question_type_index = headers.index(response.question_identifier + '_question_type')
        row[question_type_index] = survey.chronicled_question(response.question_identifier).try(:question_type) if question_type_index
        special_identifier_index = headers.index(response.question_identifier + '_special')
        row[special_identifier_index] = response.special_response if special_identifier_index
        other_identifier_index = headers.index(response.question_identifier + '_other')
        row[other_identifier_index] = response.other_response if other_identifier_index
        label_index = headers.index(response.question_identifier + '_label')
        row[label_index] = survey.option_labels(response) if label_index
        question_version_index = headers.index(response.question_identifier + '_version')
        row[question_version_index] = response.question_version if question_version_index
        question_text_index = headers.index(response.question_identifier + '_text')
        row[question_text_index] = Sanitize.fragment(survey.chronicled_question(response.question_identifier).try(:text)) if question_text_index
        start_time_index = headers.index(response.question_identifier + '_start_time')
        row[start_time_index] = response.time_started if start_time_index
        end_time_index = headers.index(response.question_identifier + '_end_time')
        row[end_time_index] = response.time_ended if end_time_index
      end
      device_user_id_index = headers.index('device_user_id')
      device_user_username_index = headers.index('device_user_username')
      device_user_ids = survey.responses.pluck(:device_user_id).uniq.compact
      unless device_user_ids.empty?
        row[device_user_id_index] = device_user_ids.join(",")
        row[device_user_username_index] = DeviceUser.find(device_user_ids).map(&:username).uniq.join(",")
      end
      csv << row
    end
    decrement_export_count(export_id.to_s)
  end

  def self.get_headers(file)
    @headers ||= Hash.new do |hash, filename|
      hash[filename] = CSV.open(filename, 'r'){|csv| csv.first}
    end
    @headers[file]
  end

  def self.export_long_csv(long_csv, model, export_id)
    interval = 0
    model.surveys.each do |survey|
      interval += 10
      LongExportWorker.perform_in(interval.seconds, long_csv.path, survey.id, export_id)
    end
  end

  def self.write_long_header(long_csv, model)
    metadata_keys = []
    model.surveys.each do |survey|
      survey.metadata.keys.each do |key|
        metadata_keys << key unless metadata_keys.include? key
      end if survey.metadata
    end
    header = %w[qid short_qid instrument_id instrument_version_number question_version_number
              instrument_title survey_id survey_uuid device_id device_uuid device_label question_type question_text
              response response_labels special_response other_response response_time_started response_time_ended
              device_user_id device_user_username] + metadata_keys
    CSV.open(long_csv, 'wb') do |csv|
      csv << header
    end
  end

  def self.write_long_row(file, survey_id, export_id)
    survey = Survey.includes(:responses).where(id: survey_id).first
    headers = get_headers(file)
    CSV .open(file, 'a+') do |csv|
      survey.responses.each do |response|
        row = [response.question_identifier, "q_#{response.question_id}", survey.instrument_id,
               response.instrument_version_number, response.question_version, survey.instrument_title,
               survey_id, response.survey_uuid, survey.device_id, survey.device_uuid,
               survey.device_label ? survey.device_label : survey.device.label,
               response.versioned_question.try(:question_type), Sanitize.fragment(response.versioned_question.try(:text)),
               response.text, response.option_labels, response.special_response, response.other_response, response.time_started,
               response.time_ended, response.device_user.try(:id), response.device_user.try(:username)]
        survey.metadata.each do |k, v|
          row[headers.index(k)] = v if headers.index(k)
        end if survey.metadata
        csv << row
      end
    end
    decrement_export_count(export_id.to_s)
  end

end
