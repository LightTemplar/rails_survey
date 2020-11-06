# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_scores
#
#  id                :integer          not null, primary key
#  score_unit_id     :integer
#  survey_score_id   :integer
#  value             :float
#  created_at        :datetime
#  updated_at        :datetime
#  uuid              :string
#  survey_score_uuid :string
#  deleted_at        :datetime
#  response_id       :integer
#

class RawScore < ApplicationRecord
  belongs_to :score_unit
  belongs_to :survey_score
  belongs_to :response

  acts_as_paranoid

  def domain
    subdomain&.domain
  end

  def subdomain
    score_unit&.subdomain
  end

  def identifier
    survey_score.identifier
  end

  def weight
    return nil if score_unit.nil? || score_unit.weight.nil?

    score_unit.weight
  end

  def weighted_score
    return nil if value.nil?

    value * weight
  end
end
