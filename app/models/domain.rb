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
#  weight          :float
#  name            :string
#

class Domain < ApplicationRecord
  belongs_to :score_scheme
  has_many :subdomains, dependent: :destroy
  has_many :raw_scores, through: :subdomains
  has_many :score_units, through: :subdomains

  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:score_scheme_id] }

  def score(survey_score)
    center = score_scheme.centers.find_by(identifier: survey_score.survey.identifier)
    units_by_title = score_units.group_by(&:title)
    unique_units = []
    units_by_title.each do |_title, su|
      unique_units << su[0]
    end
    sanitized_scores = unique_units.map(&:raw_scores).flatten.select { |score| score.survey_score_id == survey_score.id }.reject { |score| score.weighted_score(center).nil? }
    return nil if sanitized_scores.empty?

    sum_of_weights = sanitized_scores.inject(0.0) { |sum, item| sum + item.weight(center) }
    sum_of_weighted_scores = sanitized_scores.inject(0.0) { |sum, item| sum + item.weighted_score(center) }
    (sum_of_weighted_scores / sum_of_weights).round(2)
  end
end
