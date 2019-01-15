class RenumberQuestionsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'questions_reorder'

  def perform(instrument_id)
    instrument = Instrument.find instrument_id
    instrument.renumber_questions
  end
end
