class SurveyExportWorker
  include Sidekiq::Worker

  def perform(short_file, long_file, wide_file, survey_uuid, export_id)
    survey = get_survey(survey_uuid)
    survey.write_short_row(short_file, export_id)
    survey.write_long_row(long_file, export_id)
    survey.write_wide_row(wide_file, export_id)
  end

  def get_survey(survey_uuid)
    key = Response.where(survey_uuid: survey_uuid).order('updated_at ASC').try(:last).try(:updated_at)
    Rails.cache.fetch("survey-#{survey_uuid}-#{key}", expires_in: 24.hours) do
      Survey.includes(:responses).where(uuid: survey_uuid).try(:first)
    end
  end
end
