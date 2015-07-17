class ShortExportWorker
  include Sidekiq::Worker

  def perform(file, survey_id)
    Survey.write_short_row(file, survey_id)
  end
end