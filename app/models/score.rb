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
#  uuid            :string
#  survey_uuid     :string
#  device_uuid     :string
#  device_label    :string
#

class Score < ActiveRecord::Base
  belongs_to :centralized_survey, class_name: 'Survey', foreign_key: :survey_id
  belongs_to :distributed_survey, class_name: 'Survey', foreign_key: :survey_uuid
  belongs_to :score_scheme
  has_many :centralized_raw_scores, class_name: 'RawScore', foreign_key: :score_id, dependent: :destroy
  has_many :distributed_raw_scores, class_name: 'RawScore', foreign_key: :score_uuid, dependent: :destroy

  def raw_scores
    RawScore.where('score_id = ? OR score_uuid = ?', id, uuid)
  end

  def survey
    Survey.where('id = ? OR uuid = ?', survey_id, survey_uuid).try(:first)
  end

  def raw_score_sum
    raw_scores.sum(:value)
  end

  def weighted_score_sum
    raw_scores.inject(0) { |sum, item| sum + weighted_score(item) }
  end

  def weighted_score(raw_score)
    return 0 unless raw_score.value
    raw_score.value * raw_score.score_unit.weight
  end
end
