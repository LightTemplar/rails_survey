# frozen_string_literal: true

class ScoreCacheWorker
  include Sidekiq::Worker

  def perform(score_scheme_id, survey_score_id)
    score_scheme = ScoreScheme.find score_scheme_id
    survey_score = SurveyScore.find survey_score_id
    center = survey_score.center
    srs = survey_score.sanitized_raw_scores
    survey_score.score(center, srs)
    score_scheme.domains.each do |domain|
      domain.score(survey_score, center, srs)
    end
    score_scheme.subdomains.each do |subdomain|
      subdomain.score(survey_score, center, srs)
    end
    survey_score.save_scores
  end
end
