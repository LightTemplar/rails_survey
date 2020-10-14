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
    survey_score.survey.identifier
  end

  def weight(center)
    return score_unit.weight if center.nil?

    if score_unit.score_unit_questions.first.instrument_question.identifier == 'sdm6'
      if center.center_type == 'CBI'
        6
      elsif center.center_type == 'CDI'
        7
      elsif center.center_type == 'CDA'
        9
      else
        score_unit.weight
      end
    elsif score_unit.score_unit_questions.first.instrument_question.identifier == 'grp3'
      if center.center_type == 'CDA'
        9
      elsif center.center_type == 'CDI' || center.center_type == 'CBI'
        3
      else
        score_unit.weight
      end
    else
      score_unit.weight
    end
  end

  def weighted_score(center)
    return nil unless value

    value * weight(center)
  end
end
