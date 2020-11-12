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

class Instruction < ApplicationRecord
  include Sanitizable
  has_many :questions, dependent: :nullify
  has_many :option_sets, dependent: :nullify
  has_many :instrument_questions, through: :questions
  has_many :instruction_translations, dependent: :destroy
  has_many :display_instructions, dependent: :destroy

  acts_as_paranoid
  has_paper_trail

  validates :title, presence: true, allow_blank: false, uniqueness: true

  def translated_text(language, instrument)
    return text if language == instrument.language

    translation = instruction_translations.where(language: language).first
    translation&.text ? translation.text : text
  end

  def instruments
    instrument_questions.map(&:instrument) | display_instructions.map(&:instrument)
  end
end
