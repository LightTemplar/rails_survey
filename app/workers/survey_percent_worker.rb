class SurveyPercentWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'percentage'

  def perform(survey_id)
    survey = Survey.find_by_id(survey_id)
    survey.calculate_completion_rate if survey
  end
end
