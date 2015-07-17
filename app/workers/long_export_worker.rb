class LongExportWorker
  include Sidekiq::Worker

  def perform(file, survey_id, headers)
    Survey.write_long_row(file, survey_id, headers)
  end
end