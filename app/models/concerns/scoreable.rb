# frozen_string_literal: true

module Scoreable
  extend ActiveSupport::Concern

  def generate_score(score_units, survey_score_id, center)
    units_by_title = score_units.group_by(&:title)
    unique_units = []
    units_by_title.each do |_title, su|
      unique_units << su[0]
    end
    sanitized_scores = unique_units.map(&:raw_scores).flatten.select { |rs| rs.survey_score_id == survey_score_id }.reject { |rs| rs.weighted_score(center).nil? }
    return nil if sanitized_scores.empty?

    sum_of_weights = sanitized_scores.inject(0.0) { |sum, item| sum + item.weight(center) }
    sum_of_weighted_scores = sanitized_scores.inject(0.0) { |sum, item| sum + item.weighted_score(center) }
    (sum_of_weighted_scores / sum_of_weights).round(2)
  end
end
