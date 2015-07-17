class WideExportWorker
  include Sidekiq::Worker

  def perform(file, survey_id, headers)
    Survey.write_wide_row(file, survey_id, headers)
  end
end