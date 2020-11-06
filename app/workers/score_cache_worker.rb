# frozen_string_literal: true

class ScoreCacheWorker
  include Sidekiq::Worker

  def perform(score_scheme_id, survey_score_id)
    score_scheme = ScoreScheme.find score_scheme_id
    survey_score = SurveyScore.find survey_score_id
    srs = survey_score.sanitized_raw_scores
    survey_score.score(srs)
    score_scheme.domains.each do |domain|
      domain.score(survey_score, srs)
    end
    score_scheme.subdomains.each do |subdomain|
      subdomain.score(survey_score, srs)
    end
    survey_score.save_scores
  end
end
