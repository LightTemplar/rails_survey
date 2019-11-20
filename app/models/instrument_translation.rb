# frozen_string_literal: true

# == Schema Information
#
# Table name: instrument_translations
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  language      :string
#  alignment     :string
#  title         :string
#  created_at    :datetime
#  updated_at    :datetime
#  active        :boolean          default(FALSE)
#

class InstrumentTranslation < ApplicationRecord
  include Alignable
  include LanguageAssignable
  include GoogleTranslatable
  belongs_to :instrument, touch: true
  after_save :deactive_language_translations, if: :active?
  has_many :question_translations, dependent: :destroy
  has_many :option_translations, dependent: :destroy
  has_many :section_translations, dependent: :destroy
  has_many :grid_translations, dependent: :destroy
  has_many :grid_label_translations, dependent: :destroy
  has_many :randomized_option_translations, dependent: :destroy

  validates :title, presence: true, allow_blank: false
  validates :language, presence: true, allow_blank: false
  validates :instrument_id, presence: true, allow_blank: false

  # Used to migrate child translations that were not associated with an instrument_translation
  def assign_old_translations
    instrument.questions.each do |question|
      question.translations.where(language: language).update_all(instrument_translation_id: id)
    end
    instrument.options.each do |option|
      option.translations.where(language: language).update_all(instrument_translation_id: id)
    end
    instrument.sections.each do |section|
      section.translations.where(language: language).update_all(instrument_translation_id: id)
    end
  end

  def deactive_language_translations
    InstrumentTranslation.where('id != ? AND language = ?', id, language).update_all(active: false)
  end

  def translate_using_google
    title_translation = translation_client.translate sanitize_text(instrument.title), to: language unless instrument.title.blank?
    self.title = title_translation.text if title_translation
    save
  end

  def self.import(file_path)
    csv_data = CSV.read(file_path)
    instrument = Instrument.where(id: csv_data[0][1].to_i).try(:first)
    instrument_translation = instrument.translations.new(language: csv_data[1][1], alignment: csv_data[2][1], title: csv_data[3][2]) if instrument
    if instrument_translation.save
      sector_count = 0
      csv_data.drop(7).each do |row|
        if row.compact.size.zero?
          sector_count += 1
          next
        end
        next if row[0].strip == 'question_identifier' || row[0].strip == 'option_id' || row[0].strip == 'section_id'

        if sector_count.zero?
          question = Question.where(question_identifier: row[0].strip).try(:first)
          question.translations.create(language: csv_data[1][1], text: row[2], instructions: row[4], instrument_translation_id: instrument_translation.id, reg_ex_validation_message: row[6]) if question && row[2]
        elsif sector_count == 1
          option = Option.where(id: row[0].strip.to_i).try(:first)
          option.translations.create(language: csv_data[1][1], text: row[2], instrument_translation_id: instrument_translation.id) if option && row[2]
        elsif sector_count == 2
          section = Section.where(id: row[0].strip.to_i).try(:first)
          section.translations.create(language: csv_data[1][1], text: row[1], instrument_translation_id: instrument_translation.id) if section && row[2]
        end
      end
    end
  end

  def translation_for(object)
    case object
    when Question then question_translations.where(question_id: object.id).try(:first)
    when Option then option_translations.where(option_id: object.id).try(:first)
    when Section then section_translations.where(section_id: object.id).try(:first)
    when Grid then grid_translations.where(grid_id: object.id).try(:first)
    when GridLabel then grid_label_translations.where(grid_label_id: object.id).try(:first)
    when RandomizedOption then randomized_option_translations.where(randomized_option_id: object.id).try(:first)
    end
  end

  def translation_for_child(object)
    case object
    when Question then question_translations.where(question_id: object.id).first_or_initialize
    when Option then option_translations.where(option_id: object.id).first_or_initialize
    when Section then section_translations.where(section_id: object.id).first_or_initialize
    when RandomizedOption then randomized_option_translations.where(randomized_option_id: object.id).first_or_initialize
    end
  end

  def language_translation_for(object)
    case object
    when Question then QuestionTranslation.where('question_id = ? AND language = ?', object.id, language).try(:first)
    when Option then OptionTranslation.where('option_id = ? AND language = ?', object.id, language).try(:first)
    when Instruction then InstructionTranslation.where('instruction_id = ? AND language = ?', object.id, language).try(:first)
      # when Section then SectionTranslation.where('section_id = ? AND language = ?',
      #   object.id, language).try(:first)
      # when Grid then grid_translations.where(grid_id: object.id).try(:first)
      # when GridLabel then grid_label_translations.where(grid_label_id: object.id).try(:first)
    end
  end
end
