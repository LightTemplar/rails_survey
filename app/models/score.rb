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
end
