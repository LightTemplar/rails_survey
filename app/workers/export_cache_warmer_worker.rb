class ExportCacheWarmerWorker
  include Sidekiq::Worker

  def perform
    Instrument.where(auto_export_responses: true).each(&:export_surveys)
  end
end
