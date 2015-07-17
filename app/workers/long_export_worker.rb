class LongExportWorker
  include Sidekiq::Worker

  def perform(file, survey_id, headers, export_id)
    Survey.write_long_row(file, survey_id, headers, export_id)
  end
end