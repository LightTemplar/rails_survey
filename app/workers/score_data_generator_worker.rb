# frozen_string_literal: true

class ScoreDataGeneratorWorker
  include Sidekiq::Worker

  def perform(survey_score_id, operator, weight)
    survey_score = SurveyScore.find survey_score_id
    score_datum = survey_score.score_data.where(operator: operator, weight: weight).first
    score_datum ||= ScoreDatum.create(survey_score_id: survey_score_id, operator: operator, weight: weight)
    survey_score.generate_score_data(score_datum)
  end
end
