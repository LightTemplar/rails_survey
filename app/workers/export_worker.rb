class ExportWorker
  include Sidekiq::Worker

  def perform(instrument_id)
    instrument = Instrument.find(instrument_id)
    instrument.export_surveys if instrument
  end
end
