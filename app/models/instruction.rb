# frozen_string_literal: true

# == Schema Information
#
# Table name: instructions
#
#  id         :integer          not null, primary key
#  title      :string
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class Instruction < ActiveRecord::Base
  has_many :questions, dependent: :nullify
  has_many :option_sets, dependent: :nullify
  has_many :instrument_questions, through: :questions
  has_many :instruction_translations, dependent: :destroy
  has_many :display_instructions, dependent: :destroy
  acts_as_paranoid
  has_paper_trail
  after_touch :touch_instrument_questions, :touch_display_instructions, :touch_instrument
  after_commit :touch_instrument_questions, :touch_display_instructions, :touch_instrument

  def translated(code)
    trans = instruction_translations.where(language: code)
    "<ul>#{trans.map { |translation| "<li>#{translation.text}</li>" }.join}</ul>" unless trans.empty?
  end

  def question_identifiers
    "<ul>#{questions.map { |q| "<li>#{q.question_identifier}</li>" }.join}</ul>" unless questions.empty?
  end

  def option_set_titles
    "<ul>#{option_sets.map { |os| "<li>#{os.title}</li>" }.join}</ul>" unless option_sets.empty?
  end

  def display_titles
    "<ul>#{display_instructions.map { |di| "<li>#{di.display.title}</li>" }.join}</ul>" unless display_instructions.empty?
  end

  def question_identifier_lines
    questions.map(&:question_identifier).join("\, ") unless questions.empty?
  end

  def option_set_title_lines
    option_sets.map(&:title).join("\, ") unless option_sets.empty?
  end

  def display_title_lines
    display_instructions.map { |di| di.display.title }.join("\, ") unless display_instructions.empty?
  end

  def translated_lines(code)
    trans = instruction_translations.where(language: code)
    sanitizer = Rails::Html::FullSanitizer.new
    trans.map { |translation| sanitizer.sanitize translation.text }.join("\, ") unless trans.empty?
  end

  def self.export
    sanitizer = Rails::Html::FullSanitizer.new
    CSV.generate do |csv|
      csv << %w[title questions option_sets subsections english swahili amharic khmer]
      Instruction.all.each do |instruction|
        csv << [sanitizer.sanitize(instruction.title), instruction.question_identifier_lines,
                instruction.option_set_title_lines, instruction.display_title_lines,
                sanitizer.sanitize(instruction.text), instruction.translated_lines('sw'),
                instruction.translated_lines('am'), instruction.translated_lines('km')]
      end
    end
  end

  def translated_text(language, instrument)
    return text if language == instrument.language

    translation = instruction_translations.where(language: language).first
    translation&.text ? translation.text : text
  end

  def instruments
    instrument_questions.map(&:instrument) | display_instructions.map(&:instrument)
  end

  private

  def touch_instrument_questions
    instrument_questions.update_all(updated_at: Time.now)
  end

  def touch_display_instructions
    display_instructions.update_all(updated_at: Time.now)
  end

  def touch_instrument
    instruments.map(&:touch)
  end
end
