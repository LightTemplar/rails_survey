# frozen_string_literal: true

# == Schema Information
#
# Table name: instruments
#
#  id                         :integer          not null, primary key
#  title                      :string
#  created_at                 :datetime
#  updated_at                 :datetime
#  language                   :string
#  alignment                  :string
#  instrument_questions_count :integer          default(0)
#  project_id                 :integer
#  published                  :boolean
#  deleted_at                 :datetime
#  require_responses          :boolean          default(FALSE)
#  scorable                   :boolean          default(FALSE)
#  auto_export_responses      :boolean          default(TRUE)
#

class Instrument < ApplicationRecord
  include Translatable
  include Alignable
  include LanguageAssignable
  include Sanitizable
  scope :published, -> { where(published: true) }
  belongs_to :project, touch: true

  has_many :instrument_questions, -> { order(number_in_instrument: :asc) }, dependent: :destroy
  has_many :questions, -> { distinct }, through: :instrument_questions
  has_many :question_translations, through: :questions, source: :translations
  has_many :option_sets, -> { distinct }, through: :questions
  has_many :option_translations, through: :options, source: :translations
  has_many :option_in_option_sets, through: :option_sets
  has_many :options, through: :option_in_option_sets
  has_many :displays, -> { order(position: :asc) }, dependent: :destroy
  has_many :display_translations, through: :displays
  has_many :instrument_rules
  has_many :translations, class_name: 'InstrumentTranslation', dependent: :destroy
  has_many :surveys
  has_many :responses, through: :surveys
  has_many :response_images, through: :responses
  has_one :response_export
  has_many :sections, -> { order 'position' }, dependent: :destroy
  has_many :section_translations, through: :sections, source: :translations
  has_many :rules, through: :instrument_rules
  has_many :grids, dependent: :destroy
  has_many :grid_labels, through: :grids
  has_many :metrics, dependent: :destroy
  has_many :rosters
  has_many :randomized_factors, dependent: :destroy
  has_many :randomized_options, through: :randomized_factors
  has_many :next_questions, -> { order 'instrument_questions.number_in_instrument' }, through: :instrument_questions
  has_many :multiple_skips, -> { order 'instrument_questions.number_in_instrument' }, through: :instrument_questions
  has_many :critical_responses, through: :questions
  has_many :loop_questions, through: :instrument_questions
  has_many :score_schemes, dependent: :destroy
  has_many :score_units, through: :score_schemes
  has_many :red_flags, through: :instrument_questions
  has_many :tasks, through: :questions
  has_many :task_option_sets, through: :tasks

  has_paper_trail
  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:project_id] }
  validates :project_id, presence: true, allow_blank: false

  def language_name(name = language)
    Settings.languages.to_h.key(name)
  end

  def available_languages
    [language] + question_translations.pluck(:language).uniq.compact
  end

  def self.create_translations
    Instrument.all.find_each do |instrument|
      languages = instrument.question_translations.pluck(:language).uniq
      languages.each do |translation_language|
        instrument_translation = instrument.translations.where(language: translation_language).first
        unless instrument_translation
          instrument.translations.create!(language: translation_language, title: instrument.title,
                                          alignment: instrument.alignment)
        end
      end
    end
  end

  def order_displays
    position = 1
    ActiveRecord::Base.transaction do
      sections.each do |section|
        section.displays.each do |display|
          display.update_columns(instrument_position: position)
          position += 1
        end
      end
    end
    reload
  end

  def order_instrument_questions
    s_position = 1
    d_position = 1
    position = 1
    ActiveRecord::Base.transaction do
      sections.each do |section|
        section.update_columns(position: s_position)
        s_position += 1
        pos = 1
        section.displays.each do |display|
          display.update_columns(instrument_id: id, instrument_position: d_position, position: pos)
          Display.reset_counters(display.id, :instrument_questions)
          d_position += 1
          pos += 1
          display.instrument_questions.each do |instrument_question|
            instrument_question.update_columns(number_in_instrument: position, instrument_id: id)
            position += 1
          end
        end
      end
      Instrument.reset_counters(id, :instrument_questions)
    end
    reload
  end

  def set_skip_patterns
    ActiveRecord::Base.transaction do
      SkipPattern.all.find_each do |pattern|
        nq = next_questions.where(
          option_identifier: pattern.option_identifier,
          question_identifier: pattern.question_identifier,
          next_question_identifier: pattern.next_question_identifier
        ).first
        next if nq

        iq = instrument_questions.where(identifier: pattern.question_identifier).first
        niq = instrument_questions.where(identifier: pattern.next_question_identifier).first
        oi_present = iq.options.pluck(:identifier).include?(pattern.option_identifier) if iq && niq
        next unless oi_present

        NextQuestion.create!(
          option_identifier: pattern.option_identifier,
          question_identifier: pattern.question_identifier,
          next_question_identifier: pattern.next_question_identifier,
          instrument_question_id: iq.id
        )
      end
    end
  end

  def copy(project, display)
    instrument_copy = dup
    instrument_copy.project_id = project.id
    instrument_copy.title = title + "_#{Time.now.to_i}"
    instrument_copy.save!
    ActiveRecord::Base.transaction do
      if display == 'AS_IT_IS'
        displays.each do |display|
          display_copy = display.dup
          display_copy.instrument_id = instrument_copy.id
          display_copy.save!
          display.instrument_questions.order(:number_in_instrument).each do |iq|
            iq.copy(display_copy.id, instrument_copy.id)
          end
        end
      elsif display == 'ONE_QUESTION_PER_SCREEN'
        index = 0
        instrument_questions.order(:number_in_instrument).each do |iq|
          index += 1
          display_copy = Display.create!(mode: 'SINGLE', position: index, instrument_id: instrument_copy.id, title: index.to_s)
          iq.copy(display_copy.id, instrument_copy.id)
        end
      elsif display == 'ALL_QUESTIONS_ON_ONE_SCREEN'
        display_copy = Display.create!(mode: 'MULTIPLE', position: 1, instrument_id: instrument_copy.id, title: 'Questions')
        instrument_questions.order(:number_in_instrument).each do |iq|
          iq.copy(display_copy.id, instrument_copy.id)
        end
      end
    end
    instrument_copy
  end

  def delete_duplicate_surveys
    grouped_surveys = surveys.group_by(&:uuid)
    grouped_surveys.values.each do |duplicates|
      duplicates.shift
      duplicates.map(&:delete)
    end
  end

  def version_by_version_number(version_number)
    return nil if version_number > versions.size || version_number <= 0

    versions[version_number - 1].reify
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
    instrument_questions.count
  end

  def section_count
    sections.count
  end

  def display_count
    displays.count
  end

  def survey_instrument_versions
    surveys.pluck(:instrument_version_number).uniq
  end

  def to_excel(file)
    Axlsx::Package.new do |p|
      wb = p.workbook
      wb.add_worksheet(name: title) do |sheet|
        export(sheet)
      end
      p.serialize(file.path)
    end
    file
  end

  def export(sheet)
    write_instrument_attributes(sheet)
    languages = instrument_translation_languages
    sheet.add_row(%w[section display number identifier type text images] + languages)
    sections.each do |section|
      section.displays.each_with_index do |display, index|
        sheet.add_row(index.zero? ? [section.title, display.title] : ['', display.title])
        display.instrument_questions.each do |iq|
          sheet.add_row(['', '', iq.number_in_instrument, iq.identifier,
                         iq.question_type, full_sanitize(iq.question_text),
                         full_sanitize(iq.question_diagram_images)] +
                    translations_for_object(iq, languages))
          iq.non_special_options.each do |option|
            sheet.add_row(['', '', '', '', '', full_sanitize(option.text),
                           full_sanitize(iq.diagram_images(option))] +
                      translations_for_object(option, languages))
          end
        end
      end
    end
  end

  def write_instrument_attributes(sheet)
    sheet.add_row ['Instrument id:', id]
    sheet.add_row ['Instrument title:', title]
    sheet.add_row ['Version number:', current_version_number]
    sheet.add_row ['Language:', language]
    sheet.add_row ["\n"]
  end

  def instrument_translation_languages
    translation_languages = []
    translations.each do |t_language|
      translation_languages << t_language.language
    end
    translation_languages
  end

  def question_text_translation(obj, languages)
    translation_list = []
    languages.each do |language|
      str = ''
      it = obj.question.instruction&.instruction_translations&.where(language: language)&.first
      str += full_sanitize(it.text) if it
      qt = obj.translations&.where(language: language)&.first
      str += "\n" if str.present? && qt
      str += full_sanitize(qt.text) if qt
      ati = obj.question.after_text_instruction&.instruction_translations&.where(language: language)&.first
      str += "\n" if str.present? && ati
      str += full_sanitize(ati.text) if ati
      osi = obj.question.option_set&.instruction&.instruction_translations&.where(language: language)&.first
      str += "\n" if str.present? && osi
      str += full_sanitize(osi.text) if osi
      translation_list << str
    end
    translation_list
  end

  def translations_for_object(obj, languages)
    text_translations = []
    if obj.instance_of?(::InstrumentQuestion)
      question_text_translation(obj, languages).each do |translation|
        text_translations << translation
      end
    else
      languages.each do |language|
        ot = obj.translations.where(language: language).first
        transl_text = ot.nil? ? '' : full_sanitize(ot.text)
        text_translations << transl_text
      end
    end
    text_translations
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
    csv << ['instrument_title', full_sanitize(title), '', 'Enter instrument_title translation in column 3']
    csv << ['']
    csv << ['question_identifier', 'question_text', 'Enter question_text translations in this column', 'instructions', 'Enter instructions translations in this column', 'reg_ex_validation_message', 'Enter reg_ex_validation_message translations in this column']
    questions.each do |question|
      csv << [question.question_identifier, full_sanitize(question.text), '', full_sanitize(question.instructions), '', full_sanitize(question.reg_ex_validation_message), '']
    end
    csv << ['']
    csv << ['option_id', 'option_text', 'Enter option_text translation in this column']
    options.regular.each do |option|
      csv << [option.id, full_sanitize(option.text), '']
    end
    csv << ['']
    csv << ['section_id', 'section_title_text', 'Enter section_title_text translation in this column']
    sections.each do |section|
      csv << [section.id, full_sanitize(section.title), '']
    end
  end

  def export_surveys
    unless response_export
      ResponseExport.create(instrument_id: id, instrument_versions: survey_instrument_versions)
      reload
    end
    response_export.update_attributes(completion: 0.0)
    write_export_rows
    export_response_images
  end

  def export_response_images
    return if response_images.empty?

    file = File.new(File.join('files', 'exports').to_s + "/#{Time.now.to_i}.zip", 'a+')
    file.close
    export = ResponseImagesExport.create(response_export_id: response_export.id, download_url: file.path)
    InstrumentImagesExportWorker.perform_async(id, file.path, export.id)
  end

  def write_export_rows
    surveys.each do |survey|
      SurveyExportWorker.perform_async(survey.uuid)
    end
    StatusWorker.perform_in(10.seconds, response_export.id)
  end

  def long_headers
    %w[question_identifier short_qid instrument_id instrument_version_number question_version_number
       instrument_title survey_id survey_uuid device_id device_uuid device_label
       question_type question_text response response_labels other_text special_response
       other_response response_time_started response_time_ended device_user_id
       device_user_username survey_start_time survey_end_time duration_in_seconds] + metadata_keys
  end

  def create_loop_question(lq, variable_identifiers, question_identifier_variables, idx)
    identifier = "#{lq.parent}_#{lq.looped}_#{idx}"
    variable_identifiers << identifier unless variable_identifiers.include? identifier
    question_identifier_variables.each do |variable|
      variable_identifiers << (identifier + variable) unless variable_identifiers.include? identifier + variable
    end
  end

  def wide_headers
    variable_identifiers = []
    question_identifier_variables = %w[_short_qid _question_type _label _other_text _special
                                       _other _version _text _start_time _end_time]
    iqs = Rails.cache.fetch("instrument-questions-#{id}-#{instrument_questions.maximum('updated_at')}",
                            expires_in: 30.minutes) do
      instrument_questions.order(:number_in_instrument)
    end
    iqs.each do |iq|
      if iq.loop_questions.empty?
        variable_identifiers << iq.identifier unless variable_identifiers.include? iq.identifier
        question_identifier_variables.each do |variable|
          variable_identifiers << (iq.identifier + variable) unless variable_identifiers.include? iq.identifier + variable
        end
      else
        iq.loop_questions.each do |lq|
          if iq.question.question_type == 'INTEGER'
            (1..12).each do |n|
              create_loop_question(lq, variable_identifiers, question_identifier_variables, n)
            end
          elsif lq.option_indices.present?
            lq.option_indices.split(',').each do |ind|
              create_loop_question(lq, variable_identifiers, question_identifier_variables, ind)
            end
          else
            iq.question.options.each_with_index do |_option, idx|
              create_loop_question(lq, variable_identifiers, question_identifier_variables, idx)
            end
          end
        end
      end
    end
    variable_identifiers.map! { |identifier| "q_#{identifier}" }
    %w[survey_id survey_uuid device_identifier device_label latitude longitude
       instrument_id instrument_version_number instrument_title survey_start_time
       survey_end_time duration_in_seconds device_user_id device_user_username] + metadata_keys + variable_identifiers
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

  def reorder_display_text
    text = ''
    questions.each do |question|
      text << "#{question.question_identifier}\t#{question.number_in_instrument}\t#{full_sanitize(question.text).truncate(50)}\n"
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
      questions.where(question_identifier: qid).try(:first).try(:destroy) unless real_qids.include?(qid)
    end
    # Update positions of reordered questions
    real_qids.each_with_index do |qid, index|
      question = questions.where(question_identifier: qid).first
      question&.update_attribute(:number_in_instrument, index + 1)
    end
  end

  def reorder(order)
    ActiveRecord::Base.transaction do
      reordered_displays = order.strip.split("\n\n")
      display_position = 1
      number_in_instrument = 1
      preserved_displays = []
      preserved_questions = []
      reordered_displays.each do |dis|
        display_string = dis.split(/: /, 2)
        display = displays.find(display_string[0].to_i)
        display&.update_attribute(:position, display_position)
        display_position += 1
        preserved_displays << display
        display_and_questions = display_string[1].split(/\n\t/)
        display_and_questions.drop(1).each do |qid|
          iq = instrument_questions.where(identifier: qid).first
          iq&.update_attribute(:number_in_instrument, number_in_instrument)
          number_in_instrument += 1
          preserved_questions << iq
        end
      end
      (displays - preserved_displays).each(&:destroy)
      (instrument_questions - preserved_questions).each(&:destroy)
    end
  end
end
