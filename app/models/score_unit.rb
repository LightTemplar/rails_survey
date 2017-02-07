# == Schema Information
#
# Table name: score_units
#
#  id              :integer          not null, primary key
#  score_scheme_id :integer
#  question_type   :string(255)
#  min             :float
#  max             :float
#  weight          :float
#  created_at      :datetime
#  updated_at      :datetime
#

class ScoreUnit < ActiveRecord::Base
  belongs_to :score_scheme
  has_many :score_unit_questions, dependent: :destroy
  has_many :questions, through: :score_unit_questions
  has_many :option_scores, dependent: :destroy
  has_many :raw_scores
end
