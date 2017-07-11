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
  has_many :response_exports
  has_many :sections, dependent: :destroy
  has_many :rules, dependent: :destroy
  has_many :grids, dependent: :destroy
  has_many :grid_labels, through: :grids
  has_many :metrics, dependent: :destroy
  has_many :rosters
  has_many :score_schemes, dependent: :destroy
  has_many :randomized_factors, dependent: :destroy
  has_many :randomized_options, through: :randomized_factors

  has_paper_trail on: [:update, :destroy]
  acts_as_paranoid
  before_save :update_question_count
  after_update :update_special_options
  validates :title, presence: true, allow_blank: false
  validates :project_id, presence: true, allow_blank: false

  @sanitizer = Rails::Html::FullSanitizer.new

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
    Rails.cache.fetch("instruments-#{id}-#{version_number}", expires_in: 24.hours) do
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
    format << ['Instrument id:', id]
    format << ['Instrument title:', title]
    format << ['Version number:', current_version_number]
    format << ['Language:', language]
    format << ["\n"]
    format << %w(number_in_instrument question_identifier question_type question_instructions question_text) + instrument_translation_languages
    questions.each do |question|
      format << [question.number_in_instrument, question.question_identifier, question.question_type, @sanitizer.sanitize(question.instructions), @sanitizer.sanitize(question.text)] + translations_for_object(question)
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
    text_translations = []
    obj.translations.each do |translation|
      if instrument_translation_languages.include? translation.language
        text_translations << @sanitizer.sanitize(translation.text)
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
    csv << ['instrument_id', id]
    csv << ['translation_language_iso_code', '', 'Enter language ISO 639-1 code in column 2']
    csv << ['language_alignment', '', 'Enter left in column 2 if words in the language are read left-to-right or right if they are read right-to-left']
    csv << ['instrument_title', @sanitizer.sanitize(title), '', 'Enter instrument_title translation in column 3']
    csv << ['instrument_critical_message', @sanitizer.sanitize(critical_message), '', 'Enter critical message translation in column 3']
    csv << ['']
    csv << ['question_identifier',	'question_text',	'Enter question_text translations in this column',	'instructions',	'Enter instructions translations in this column',	'reg_ex_validation_message',	'Enter reg_ex_validation_message translations in this column']
    questions.each do |question|
      csv << [question.question_identifier, @sanitizer.sanitize(question.text), '', @sanitizer.sanitize(question.instructions), '', @sanitizer.sanitize(question.reg_ex_validation_message), '']
    end
    csv << ['']
    csv << ['option_id',	'option_text',	'Enter option_text translation in this column']
    options.regular.each do |option|
      csv << [option.id, @sanitizer.sanitize(option.text), '']
    end
    csv << ['']
    csv << ['section_id',	'section_title_text',	'Enter section_title_text translation in this column']
    sections.each do |section|
      csv << [section.id, @sanitizer.sanitize(section.title), '']
    end
  end

  def export_surveys
    files = create_files
    export = ResponseExport.create(instrument_id: id, instrument_versions: survey_instrument_versions, short_format_url: files[0].path, long_format_url: files[1].path, wide_format_url: files[2].path)
    write_export_headers(files)
    export_counter_by_format(export.id)
    write_export_rows(files, export.id)
    export.id
  end

  def export_counter_by_format(export_id)
    export_formats.each do |format|
      set_export_count("#{export_id}_#{format}", surveys.count)
    end
  end

  def write_export_headers(files)
    file_headers = { files[0] => short_headers, files[1] => long_headers, files[2] => wide_headers }
    file_headers.each do |file, header|
      CSV.open(file, 'wb') do |csv|
        csv << header
      end
    end
  end

  def write_export_rows(files, export_id)
    surveys.each do |survey|
      SurveyExportWorker.perform_async(survey.uuid, export_id)
    end
    files.each do |file|
      StatusWorker.perform_in(10.seconds, export_id, file.path)
    end
  end

  def create_files
    files = []
    root = File.join('files', 'exports').to_s
    export_formats.each do |format|
      file = File.new(root + "/#{Time.now.to_i}_#{title}_#{format}.csv", 'a+')
      file.close
      files << file
    end
    files
  end

  def export_formats
    %w(short long wide)
  end

  def short_headers
    %w(identifier survey_id question_identifier question_text response_text response_label special_response other_response)
  end

  def long_headers
    %w(qid short_qid instrument_id instrument_version_number question_version_number instrument_title survey_id survey_uuid device_id device_uuid device_label question_type question_text response response_labels special_response other_response response_time_started response_time_ended device_user_id device_user_username) + metadata_keys
  end

  def wide_headers
    variable_identifiers = []
    question_identifier_variables = %w(_short_qid _question_type _label _special _other _version _text _start_time _end_time)
    questions.each do |question|
      variable_identifiers << question.question_identifier unless variable_identifiers.include? question.question_identifier
      question_identifier_variables.each do |variable|
        variable_identifiers << question.question_identifier + variable unless variable_identifiers.include? question.question_identifier + variable
      end
    end
    %w(survey_id survey_uuid device_identifier device_label latitude longitude instrument_id instrument_version_number instrument_title survey_start_time survey_end_time device_user_id device_user_username) + metadata_keys + variable_identifiers
  end

  def metadata_keys
    last_update = surveys.order('updated_at ASC').try(:last).try(:updated_at)
    Rails.cache.fetch("survey-metadata-#{id}-#{last_update}", expires_in: 24.hours) do
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

  def fetch_csv_data(file, format, export_id)
    data = []
    keys = $redis.lrange "#{format}-keys-#{id}-#{export_id}", 0, -1
    $redis.del "#{format}-keys-#{id}-#{export_id}"
    keys.each do |key|
      data_row = $redis.lrange key, 0, -1
      data << data_row
      $redis.del key
    end
    dump_csv_data(data, file)
    complete_export(export_id, format)
  end

  def dump_csv_data(data, file)
    CSV.open(file, 'a+') do |csv|
      data.each do |row|
        csv << row
      end
    end
  end

  def complete_export(export_id, format)
    export = ResponseExport.find(export_id)
    if format == 'short'
      export.update(short_done: true)
    elsif format == 'long'
      export.update(long_done: true)
    elsif format == 'wide'
      export.update(wide_done: true)
    end
  end

  private

  def update_question_count
    self.previous_question_count = questions.count
  end
end
