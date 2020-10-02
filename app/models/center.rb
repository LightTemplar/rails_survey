# frozen_string_literal: true

# == Schema Information
#
# Table name: centers
#
#  id             :bigint           not null, primary key
#  identifier     :string
#  name           :string
#  center_type    :string
#  administration :string
#  region         :string
#  department     :string
#  municipality   :string
#  score_data     :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Center < ApplicationRecord
  has_many :score_scheme_centers, dependent: :destroy
  has_many :score_schemes, through: :score_scheme_centers
  has_many :survey_scores, foreign_key: :identifier, primary_key: :identifier

  validates :identifier, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false
  validates :center_type, presence: true, allow_blank: false

  default_scope { order :identifier }

  def score(survey_score, score_scheme)
    units_by_title = score_scheme.score_units.group_by(&:title)
    unique_units = []
    units_by_title.each do |_title, su|
      unique_units << su[0]
    end
    sanitized_scores = unique_units.map(&:raw_scores).flatten.select { |score| score.survey_score_id == survey_score.id }.reject { |score| score.weighted_score(self).nil? }
    return nil if sanitized_scores.empty?

    sum_of_weights = sanitized_scores.inject(0.0) { |sum, item| sum + item.weight(self) }
    sum_of_weighted_scores = sanitized_scores.inject(0.0) { |sum, item| sum + item.weighted_score(self) }
    (sum_of_weighted_scores / sum_of_weights).round(2)
  end
end
