class InstrumentCopyWorker
  include Sidekiq::Worker

  def perform(instrument_id, project_id)
    instrument = Instrument.find instrument_id
    instrument.copy(project_id)
  end

end