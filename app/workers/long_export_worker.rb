class LongExportWorker
  include Sidekiq::Worker

  def perform(file, survey_uuid, export_id)
    Survey.write_long_row(file, survey_uuid, export_id)
  end
end
