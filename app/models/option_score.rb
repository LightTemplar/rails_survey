# frozen_string_literal: true

# == Schema Information
#
# Table name: option_scores
#
#  id                     :integer          not null, primary key
#  score_unit_question_id :integer
#  value                  :float
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#  option_identifier      :string
#  notes                  :text
#

class OptionScore < ApplicationRecord
  belongs_to :score_unit_question
  belongs_to :option, foreign_key: :option_identifier, primary_key: :identifier

  acts_as_paranoid

  validates :score_unit_question_id, presence: true, allow_blank: false
  validates :option_identifier, presence: true, uniqueness: { scope: [:score_unit_question_id] }
  validates :value, presence: true

  def question_identifier
    score_unit_question.question_identifier
  end
end
