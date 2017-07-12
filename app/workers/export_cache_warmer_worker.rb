class ExportCacheWarmerWorker
  include Sidekiq::Worker

  # Pass export_id of -1 to SurveyExportWorker to prevent redis db pollution with non-real export entries
  def perform
    Instrument.all.each do |ins|
      ins.surveys.each do |sur|
        SurveyExportWorker.perform_async(sur.uuid, -1)
      end
    end
  end
end
