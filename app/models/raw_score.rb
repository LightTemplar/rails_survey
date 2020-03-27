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
#

class RawScore < ApplicationRecord
  belongs_to :score_unit
  belongs_to :survey_score

  acts_as_paranoid

  def domain
    subdomain.domain
  end

  def subdomain
    score_unit.subdomain
  end

  def identifier
    survey_score.survey.identifier
  end

  def weight
    score_unit.weight
  end

  def weighted_score
    return nil unless value

    value * score_unit.weight
  end
end
