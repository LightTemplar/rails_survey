# frozen_string_literal: true

# == Schema Information
#
# Table name: red_flags
#
#  id                     :bigint           not null, primary key
#  instrument_question_id :integer
#  instruction_id         :integer
#  option_identifier      :string
#  selected               :boolean          default(TRUE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  score_scheme_id        :integer
#

class RedFlag < ApplicationRecord
  belongs_to :score_scheme
  belongs_to :instrument_question
  belongs_to :instruction
  belongs_to :option, foreign_key: :option_identifier, primary_key: :identifier

  delegate :instrument, to: :instrument_question

  validates :option_identifier, presence: true, allow_blank: false
  validates :instruction_id, presence: true, allow_blank: false
  validates :instrument_question_id, uniqueness: { scope: %i[instruction_id option_identifier] }

  def description
    instruction&.text
  end

  def iq_identifier
    instrument_question&.identifier
  end

  def iq_text
    instrument_question&.text
  end

  def option_text
    option&.text
  end

  def section_title
    instrument_question&.section_title
  end

  def display_title
    instrument_question&.display_title
  end
end
