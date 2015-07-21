class WideExportWorker
  include Sidekiq::Worker

  def perform(file, survey_id, export_id)
    Survey.write_wide_row(file, survey_id, export_id)
  end
end