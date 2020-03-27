# frozen_string_literal: true

# == Schema Information
#
# Table name: domains
#
#  id              :integer          not null, primary key
#  title           :string
#  score_scheme_id :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Domain < ApplicationRecord
  belongs_to :score_scheme
  has_many :subdomains, dependent: :destroy
  has_many :raw_scores, through: :subdomains

  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:score_scheme_id] }

  default_scope { order(:title) }

  def score_sum(survey_score)
    raw_scores.where(survey_score_id: survey_score.id).sum(:value)
  end

  def weighted_score_sum(survey_score)
    raw_scores.where(survey_score_id: survey_score.id).inject(0) { |sum, item| sum + weighted_score(item) }
  end

  def weighted_score(score)
    return 0 unless score.value

    score.value * score.score_unit.weight
  end

  def score(survey_score)
    sanitized_scores = raw_scores.where(survey_score_id: survey_score.id).reject { |score| score.weighted_score.nil? }
    return nil if sanitized_scores.empty?

    sum_of_weights = sanitized_scores.map(&:weight).inject(0, &:+)
    sum_of_weighted_scores = sanitized_scores.map(&:weighted_score).inject(0, &:+)
    (sum_of_weighted_scores / sum_of_weights).round(2)
  end
end
