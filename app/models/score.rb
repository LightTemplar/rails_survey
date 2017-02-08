# == Schema Information
#
# Table name: scores
#
#  id              :integer          not null, primary key
#  survey_id       :integer
#  score_scheme_id :integer
#  score_sum       :float
#  created_at      :datetime
#  updated_at      :datetime
#

class Score < ActiveRecord::Base
  belongs_to :survey
  belongs_to :score_scheme
  has_many :raw_scores, dependent: :destroy

  def raw_score_sum
    raw_scores.sum(:value)
  end

  def weighted_score_sum
    raw_scores.inject(0) { |sum, item| sum + weighted_score(item) }
  end

  def weighted_score(raw_score)
    raw_score.value * raw_score.score_unit.weight
  end
end
