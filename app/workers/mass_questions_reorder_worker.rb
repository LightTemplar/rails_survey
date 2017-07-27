class MassQuestionsReorderWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'questions_reorder'

  def perform(instrument_id, str)
    instrument = Instrument.where(id: instrument_id).first
    instrument.mass_question_reorder(str) if instrument
  end
end
