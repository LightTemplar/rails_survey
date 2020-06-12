# frozen_string_literal: true

class SurveyExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'export'

  def perform(survey_uuid)
    survey = get_survey(survey_uuid)
    SurveyExport.create(survey_id: survey.id) unless survey.survey_export

    return if survey.responses.pluck(:updated_at).max == survey.survey_export.last_response_at

    survey.survey_export.update(last_response_at: nil)

    survey.write_long_row
    survey.write_wide_row
  end

  def get_survey(survey_uuid)
    key = Response.where(survey_uuid: survey_uuid).maximum('updated_at')
    Rails.cache.fetch("survey-#{survey_uuid}-#{key}", expires_in: 30.minutes) do
      Survey.includes(:responses).where(uuid: survey_uuid).try(:first)
    end
  end
end
