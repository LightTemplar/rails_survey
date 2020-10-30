# frozen_string_literal: true

class ScoreGeneratorWorker
  include Sidekiq::Worker

  def perform(score_scheme_id, survey_id)
    score_scheme = ScoreScheme.find score_scheme_id
    survey = Survey.find survey_id
    survey_score = score_scheme.survey_scores.where(survey_id: survey_id, score_scheme_id: score_scheme_id).first
    survey_score ||= SurveyScore.create(survey_id: survey_id, score_scheme_id: score_scheme_id)
    survey_score.update_attributes(identifier: survey.identifier, score_sum: nil, score_data: nil)
    survey_score.nullify_scores
    score_scheme.generate_unit_scores(survey, survey_score)
    ScoreCacheWorker.perform_async(score_scheme_id, survey_score.id)
  end
end
