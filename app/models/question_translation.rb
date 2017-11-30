# == Schema Information
#
# Table name: question_translations
#
#  id                        :integer          not null, primary key
#  question_id               :integer
#  language                  :string
#  text                      :text
#  created_at                :datetime
#  updated_at                :datetime
#  reg_ex_validation_message :string
#  question_changed          :boolean          default(FALSE)
#  instructions              :text
#  instrument_translation_id :integer
#

class QuestionTranslation < ActiveRecord::Base
  include GoogleTranslatable
  belongs_to :question, touch: true
  belongs_to :instrument_translation, touch: true
  validates :text, presence: true, allow_blank: false

  def translate_using_google
    text_translation = translation_client.translate sanitize_text(question.text), to: language unless question.text.blank?
    self.text = text_translation.text if text_translation
    reg_ex_translation = translation_client.translate sanitize_text(question.reg_ex_validation_message), to: language unless question.reg_ex_validation_message.blank?
    self.reg_ex_validation_message = reg_ex_translation.text if reg_ex_translation
    instructions_translation = translation_client.translate sanitize_text(question.instructions), to: language unless question.instructions.blank?
    self.instructions = instructions_translation.text if instructions_translation
    save
  end

  # Returns translated instructions
  def instructions
    question.instruction.instruction_translations.where(language: language).try(:first).try(:text) if question.instruction
  end

end
