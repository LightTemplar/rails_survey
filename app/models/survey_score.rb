# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_scores
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
#  deleted_at      :datetime
#  score_data      :text
#  identifier      :string
#

class SurveyScore < ApplicationRecord
  include Scoreable
  belongs_to :score_scheme
  belongs_to :survey
  has_many :raw_scores
  has_many :domain_scores
  has_many :subdomain_scores
  has_many :domains, through: :score_scheme
  has_many :subdomains, through: :domains
  has_many :score_units, through: :subdomains

  acts_as_paranoid

  def instrument_id
    survey.instrument_id
  end

  def instrument_title
    survey.instrument_title
  end

  def title
    "#{score_scheme_id} - #{survey_id}"
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

  def center
    score_scheme.centers.find_by(identifier: survey.identifier)
  end

  def score
    update_columns(score_sum: generate_score(score_units, id, center))
  end
end
