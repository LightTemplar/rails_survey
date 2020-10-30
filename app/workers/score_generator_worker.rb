# frozen_string_literal: true

class ScoreGeneratorWorker
  include Sidekiq::Worker

  def perform(score_scheme_id, survey_id)
    score_scheme = ScoreScheme.find score_scheme_id
    survey = Survey.find survey_id
    survey_score = score_scheme.survey_scores.where(survey_id: survey_id, score_scheme_id: score_scheme_id).first
    survey_score ||= SurveyScore.create(survey_id: survey_id, score_scheme_id: score_scheme_id)
    survey_score.update_attributes(identifier: survey.identifier)
    score_scheme.generate_unit_scores(survey, survey_score)
    ScoreCacheWorker.perform_in(1.minute, score_scheme_id, survey_score.id)
  end
end
