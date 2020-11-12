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
#

class RedFlag < ApplicationRecord
  belongs_to :instrument_question
  belongs_to :instruction
  belongs_to :option, foreign_key: :option_identifier

  delegate :instrument, to: :instrument_question

  validates :option_identifier, presence: true, allow_blank: false
  validates :instruction_id, presence: true, allow_blank: false
  validates :instrument_question_id, uniqueness: { scope: %i[instruction_id option_identifier] }

  def description
    instruction&.text
  end
end
