# frozen_string_literal: true

class SurveyScoreWorker
  include Sidekiq::Worker

  def perform(score_scheme_id, survey_id, center_data)
    score_scheme = ScoreScheme.find score_scheme_id
    survey = Survey.find survey_id
    survey_score = score_scheme.survey_scores.where(survey_id: survey_id, score_scheme_id: score_scheme_id).first
    survey_score ||= SurveyScore.create(survey_id: survey_id, score_scheme_id: score_scheme_id)
    score_scheme.generate_raw_scores(survey, survey_score, center_data)
  end
end
