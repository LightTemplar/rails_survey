# == Schema Information
#
# Table name: instruments
#
#  id                      :integer          not null, primary key
#  title                   :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  language                :string(255)
#  alignment               :string(255)
#  child_update_count      :integer          default(0)
#  previous_question_count :integer
#  project_id              :integer
#  published               :boolean
#  deleted_at              :datetime
#  show_instructions       :boolean          default(FALSE)
#  special_options         :text
#  show_sections_page      :boolean          default(FALSE)
#  navigate_to_review_page :boolean          default(FALSE)
#  critical_message        :text
#  roster                  :boolean          default(FALSE)
#  roster_type             :string(255)
#  scorable                :boolean          default(FALSE)
#  auto_export_responses   :boolean          default(TRUE)
#

class Instrument < ActiveRecord::Base
  include Translatable
  include Alignable
  include LanguageAssignable
  include RedisJobTracker
  serialize :special_options, Array
  scope :published, -> { where(published: true) }
  belongs_to :project
  has_many :questions, dependent: :destroy
  has_many :options, through: :questions
  has_many :surveys
  has_many :responses, through: :surveys
  has_many :response_images, through: :responses
  has_many :translations, foreign_key: 'instrument_id', class_name: 'InstrumentTranslation', dependent: :destroy
  has_one :response_export
  has_many :sections, dependent: :destroy
  has_many :rules, dependent: :destroy
  has_many :grids, dependent: :destroy
  has_many :grid_labels, through: :grids
  has_many :metrics, dependent: :destroy
  has_many :rosters
  has_many :score_schemes, dependent: :destroy
  has_many :randomized_factors, dependent: :destroy
  has_many :randomized_options, through: :randomized_factors

  has_paper_trail on: %i[update destroy]
  acts_as_paranoid
  before_save :update_question_count
  after_update :update_special_options
  validates :title, presence: true, allow_blank: false
  validates :project_id, presence: true, allow_blank: false

  def delete_duplicate_surveys
    grouped_surveys = surveys.group_by {|survey| survey.uuid}
    grouped_surveys.values.each do |duplicates|
      duplicates.shift
      duplicates.map(&:delete)
    end
  end

  def update_special_options
    if special_options != special_options_was
      deleted_special_options = special_options_was - special_options
      options.special_options.where(text: deleted_special_options).delete_all unless deleted_special_options.blank?
      new_special_options = special_options - special_options_was
      if !new_special_options.blank? && !questions.blank?
        questions.each(&:create_special_options)
      end
    end
  end

  def version_by_version_number(version_number)
    Rails.cache.fetch("instruments-#{id}-#{version_number}", expires_in: 30.minutes) do
      InstrumentVersion.build(instrument_id: id, version_number: version_number)
    end
  end

  def completion_rate
    sum = 0.0
    surveys.each do |survey|
      sum += survey.completion_rate.to_f if survey.completion_rate
    end
    (sum / surveys.count).round(2)
  end

  def current_version_number
    versions.count
  end

  def question_count
    questions.count
  end

  def survey_instrument_versions
    surveys.pluck(:instrument_version_number).uniq
  end

  def to_csv
    CSV.generate do |csv|
      export(csv)
    end
  end

  def export(format)
    sanitizer = Rails::Html::FullSanitizer.new
    format << ['Instrument id:', id]
    format << ['Instrument title:', title]
    format << ['Version number:', current_version_number]
    format << ['Language:', language]
    format << ["\n"]
    format << %w[number_in_instrument question_identifier question_type question_instructions question_text] + instrument_translation_languages
    questions.each do |question|
      format << [question.number_in_instrument, question.question_identifier, question.question_type, sanitizer.sanitize(question.instructions), sanitizer.sanitize(question.text)] + translations_for_object(question)
      question.options.each do |option|
        format << ['', '', '', "Option for question #{question.question_identifier}", option.text] + translations_for_object(option)
        if option.next_question
          format << ['', '', '', "For option #{option}, SKIP TO question", option.next_question]
        end
        next unless option.skips
        option.skips.each do |skip|
          format << ['', '', '', "For option #{option.text}, SKIP question", skip.question_identifier]
        end
      end
      if question.reg_ex_validation_message
        format << ['', '', '', "Regular expression failure message for #{question.question_identifier}",
                   question.reg_ex_validation_message]
      end
      if question.following_up_question_identifier
        format << ['', '', '', 'Following up on question', question.following_up_question_identifier]
        format << ['', '', '', 'Follow up position', question.follow_up_position]
      end
      if question.identifies_survey
        format << ['', '', '', 'Question identifies survey', 'YES']
      end
    end
  end

  def instrument_translation_languages
    translation_languages = []
    translations.each do |t_language|
      translation_languages << t_language.language
    end
    translation_languages
  end

  def translations_for_object(obj)
    sanitizer = Rails::Html::FullSanitizer.new
    text_translations = []
    obj.translations.each do |translation|
      if instrument_translation_languages.include? translation.language
        text_translations << sanitizer.sanitize(translation.text)
      end
    end
    text_translations
  end

  def update_instrument_version
    # Force update for paper trail
    increment!(:child_update_count)
  end

  def reorder_questions(old_number, new_number)
    ActiveRecord::Base.transaction do
      # If question is moved up in instrument, settle conflicts by giving the
      # most recently updated (ie the moved question) the lower number.
      question_moved_up = old_number > new_number
      secondary_order = question_moved_up ? 'DESC' : 'ASC'

      questions.unscoped.where('instrument_id = ? AND deleted_at is null', id).order("number_in_instrument ASC, updated_at #{secondary_order}").each_with_index do |question, index|
        updated_number = index + 1
        if question.number_in_instrument != updated_number
          question.number_in_instrument = updated_number
          question.save
        end
      end
    end
  end

  def reorder_questions_after_delete(question_number)
    ActiveRecord::Base.transaction do
      questions.unscoped.where('instrument_id = ? AND number_in_instrument >= ? AND deleted_at is null', id, question_number).each_with_index do |question, _index|
        question.number_in_instrument = question.number_in_instrument - 1
        question.save
      end
    end
  end

  def translation_csv_template
    CSV.generate do |csv|
      generate_row(csv)
    end
  end

  def generate_row(csv)
    sanitizer = Rails::Html::FullSanitizer.new
    csv << ['instrument_id', id]
    csv << ['translation_language_iso_code', '', 'Enter language ISO 639-1 code in column 2']
    csv << ['language_alignment', '', 'Enter left in column 2 if words in the language are read left-to-right or right if they are read right-to-left']
    csv << ['instrument_title', sanitizer.sanitize(title), '', 'Enter instrument_title translation in column 3']
    csv << ['instrument_critical_message', sanitizer.sanitize(critical_message), '', 'Enter critical message translation in column 3']
    csv << ['']
    csv << ['question_identifier',	'question_text',	'Enter question_text translations in this column',	'instructions',	'Enter instructions translations in this column',	'reg_ex_validation_message',	'Enter reg_ex_validation_message translations in this column']
    questions.each do |question|
      csv << [question.question_identifier, sanitizer.sanitize(question.text), '', sanitizer.sanitize(question.instructions), '', sanitizer.sanitize(question.reg_ex_validation_message), '']
    end
    csv << ['']
    csv << ['option_id',	'option_text',	'Enter option_text translation in this column']
    options.regular.each do |option|
      csv << [option.id, sanitizer.sanitize(option.text), '']
    end
    csv << ['']
    csv << ['section_id',	'section_title_text',	'Enter section_title_text translation in this column']
    sections.each do |section|
      csv << [section.id, sanitizer.sanitize(section.title), '']
    end
  end

  def response_export_counter(response_export)
    export_formats.each do |format|
      set_export_count("#{response_export.id}_#{format}", surveys.count)
    end
  end

  def export_surveys(new_export = false)
    unless response_export
      ResponseExport.create(instrument_id: id, instrument_versions: survey_instrument_versions)
      reload
    end
    response_export.update_attributes(long_done: false, wide_done: false, short_done: false, completion: 0.0)
    response_export_counter(response_export)
    sanitize_redis_keys
    write_export_rows
    export_response_images
  end

  def export_response_images
    unless response_images.empty?
      file = File.new(File.join('files', 'exports').to_s + "/#{Time.now.to_i}.zip", 'a+')
      file.close
      export = ResponseImagesExport.create(response_export_id: response_export.id, download_url: file.path)
      InstrumentImagesExportWorker.perform_async(id, file.path, export.id)
    end
  end

  def sanitize_redis_keys
    $redis.del "wide-keys-#{id}-#{response_export.id}"
    $redis.del "long-keys-#{id}-#{response_export.id}"
    $redis.del "short-keys-#{id}-#{response_export.id}"
  end

  def write_export_rows
    instrument_surveys = Rails.cache.fetch("instrument-surveys-#{id}-#{surveys.maximum('updated_at')}", expires_in: 30.minutes) do
      surveys
    end
    instrument_surveys.each do |survey|
      SurveyExportWorker.perform_async(survey.uuid)
    end
    export_formats.each do |format|
      StatusWorker.perform_in(10.seconds, response_export.id, format)
    end
  end

  def export_formats
    %w[short long wide]
  end

  def get_variable_identifiers(question_identifier_variables)
    variable_identifiers = []
    instrument_questions = Rails.cache.fetch("instrument-questions-#{id}-#{questions.maximum('updated_at')}", expires_in: 30.minutes) do
      questions
    end
    instrument_questions.each do |question|
      variable_identifiers << question.question_identifier unless variable_identifiers.include? question.question_identifier
      question_identifier_variables.each do |variable|
        variable_identifiers << question.question_identifier + variable unless variable_identifiers.include? question.question_identifier + variable
      end
    end
    variable_identifiers
  end

  def short_headers
    question_identifier_variables = %w[_label _special _other _text]
    variable_identifiers = get_variable_identifiers(question_identifier_variables)
    %w[survey_id instrument_id instrument_title] + variable_identifiers
  end

  def long_headers
    %w[qid short_qid instrument_id instrument_version_number question_version_number instrument_title survey_id survey_uuid device_id device_uuid device_label question_type question_text response response_labels special_response other_response response_time_started response_time_ended device_user_id device_user_username] + metadata_keys
  end

  def wide_headers
    question_identifier_variables = %w[_short_qid _question_type _label _special _other _version _text _start_time _end_time]
    variable_identifiers = get_variable_identifiers(question_identifier_variables)
    %w[survey_id survey_uuid device_identifier device_label latitude longitude instrument_id instrument_version_number instrument_title survey_start_time survey_end_time device_user_id device_user_username] + metadata_keys + variable_identifiers
  end

  def metadata_keys
    Rails.cache.fetch("survey-metadata-#{id}-#{surveys.maximum('updated_at')}", expires_in: 30.minutes) do
      m_keys = []
      surveys.each do |survey|
        next unless survey.metadata
        survey.metadata.keys.each do |key|
          m_keys << key unless m_keys.include? key
        end
      end
      m_keys
    end
  end

  def stringify_arrays(format)
    data = []
    keys = $redis.lrange "#{format}-keys-#{id}-#{response_export.id}", 0, -1
    keys.each do |key|
      data_row = $redis.lrange key, 0, -1
      data << data_row
    end
    $redis.set "#{id}-#{response_export.id}-#{format}", data.to_s
    mark_export_as_complete(format)
  end

  def mark_export_as_complete(format)
    if format == 'short'
      response_export.update_columns(short_done: true)
    elsif format == 'long'
      response_export.update_columns(long_done: true)
    elsif format == 'wide'
      response_export.update_columns(wide_done: true)
    end
    ResponseExportCompletionWorker.perform_async(response_export.id)
  end

  def reorder_display_text
    sanitizer = Rails::Html::FullSanitizer.new
    text = ''
    questions.each do |question|
      text << "#{question.question_identifier}\t#{question.number_in_instrument}\t#{sanitizer.sanitize(question.text).truncate(50)}\n"
    end
    text
  end

  def mass_question_reorder(q_str)
    # Parse question identifiers from string parameter
    reordered_questions = q_str.strip.split("\n")
    question_identifiers = []
    reordered_questions.each do |question_line|
      question_identifiers << question_line.split("\t")[0]
    end
    # Keep valid question identifiers
    db_question_identifiers = questions.pluck(:question_identifier)
    real_qids = question_identifiers.select { |qid| db_question_identifiers.include?(qid) }
    # Delete removed questions
    db_question_identifiers.each do |qid|
      unless real_qids.include?(qid)
        questions.where(question_identifier: qid).try(:first).try(:destroy)
      end
    end
    # Update positions of reordered questions
    real_qids.each_with_index do |qid, index|
      question = questions.where(question_identifier: qid).first
      question.update_attribute(:number_in_instrument, index + 1) if question
    end
  end

  private

  def update_question_count
    self.previous_question_count = questions.count
  end
end
