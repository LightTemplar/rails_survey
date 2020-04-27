# frozen_string_literal: true

# == Schema Information
#
# Table name: subdomains
#
#  id         :integer          not null, primary key
#  title      :string
#  domain_id  :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  weight     :float
#

class Subdomain < ApplicationRecord
  belongs_to :domain
  has_many :score_units, -> { order 'score_units.title' }, dependent: :destroy
  has_many :raw_scores, through: :score_units

  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:domain_id] }

  default_scope { order(:title) }

  def score(survey_score)
    center = domain.score_scheme.centers.find_by(identifier: survey_score.survey.identifier)
    sanitized_scores = raw_scores.where(survey_score_id: survey_score.id).reject { |score| score.weighted_score(center).nil? }
    return nil if sanitized_scores.empty?

    sum_of_weights = sanitized_scores.inject(0.0) { |sum, item| sum + item.weight(center) }
    sum_of_weighted_scores = sanitized_scores.inject(0.0) { |sum, item| sum + item.weighted_score(center) }
    (sum_of_weighted_scores / sum_of_weights).round(2)
  end
end
