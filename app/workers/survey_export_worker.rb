# frozen_string_literal: true

class SurveyExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'export'

  def perform(survey_uuid)
    survey = Survey.includes(:responses).where(uuid: survey_uuid).try(:first)
    return unless survey

    SurveyExport.create(survey_id: survey.id) unless survey.survey_export
    survey.reload

    return if survey.responses.pluck(:updated_at).max == survey.survey_export.last_response_at && !survey.survey_export.wide.nil? && !survey.survey_export.long.nil?

    survey.survey_export.update(last_response_at: nil)
    survey.write_long_row
    survey.write_wide_row
  end
end
