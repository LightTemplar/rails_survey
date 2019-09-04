# frozen_string_literal: true

# == Schema Information
#
# Table name: score_unit_questions
#
#  id                     :integer          not null, primary key
#  score_unit_id          :integer
#  instrument_question_id :integer
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#

class ScoreUnitQuestion < ActiveRecord::Base
  belongs_to :score_unit
  belongs_to :instrument_question
  has_many :option_scores, dependent: :destroy

  acts_as_paranoid

  validates :score_unit_id, presence: true, allow_blank: false
  validates :instrument_question_id, presence: true, uniqueness: { scope: [:score_unit_id] }
end
