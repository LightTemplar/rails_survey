class TranslationImportWorker
  include Sidekiq::Worker

  def perform(file_path)
    InstrumentTranslation.import(file_path)
  end
  
end