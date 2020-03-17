# frozen_string_literal: true

# == Schema Information
#
# Table name: score_schemes
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  title         :string
#  created_at    :datetime
#  updated_at    :datetime
#  deleted_at    :datetime
#  active        :boolean
#

class ScoreScheme < ApplicationRecord
  belongs_to :instrument
  has_many :surveys, through: :instrument
  has_many :domains, dependent: :destroy
  has_many :subdomains, through: :domains
  has_many :score_units, through: :subdomains
  has_many :score_unit_questions, through: :score_units
  has_many :option_scores, through: :score_unit_questions
  has_many :survey_scores

  delegate :project, to: :instrument

  acts_as_paranoid

  validates :title, presence: true, uniqueness: { scope: [:instrument_id] }

  def score_unit_count
    score_units.size
  end

  def score_survey(survey)
    score = get_score(survey)
    score_units.each do |unit|
      scheme = SchemeGenerator.generate(unit)
      unit_raw_score = get_raw_score(score, unit)
      score_value = scheme.score(survey, unit)
      unit_raw_score.update(value: score_value)
    end
  end

  def get_score(survey)
    score = scores.where(survey_id: survey.id).try(:first)
    score ||= scores.create(survey_id: survey.id, score_scheme_id: id)
    score
  end

  def get_raw_score(score, unit)
    raw_score = score.raw_scores.where(score_unit_id: unit.id).try(:first)
    raw_score ||= score.raw_scores.create(score_unit_id: unit.id, score_id: score.id)
    raw_score
  end

  def score_surveys
    surveys.each do |survey|
      SurveyScoreWorker.perform_async(id, survey.id)
    end
  end

  def generate_raw_scores(survey, survey_score)
    score_units.each do |unit|
      raw_score = survey_score.raw_scores.where(score_unit_id: unit.id, survey_score_id: survey_score.id).first
      raw_score ||= RawScore.create(score_unit_id: unit.id, survey_score_id: survey_score.id)
      raw_score.value = unit.score(survey)
      raw_score.save
    end
  end
end
