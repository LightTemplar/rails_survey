class GoogleTranslateWorker
  include Sidekiq::Worker

  def perform(translation_id)
    translation = InstrumentTranslation.find(translation_id)
    translation.translate_using_google
    translation.instrument.questions.each do |question|
      question_translation = QuestionTranslation.new(question_id: question.id, language: translation.language)
      question_translation.translate_using_google
      question.non_special_options.each do |option|
        option_translation = OptionTranslation.new(option_id: option.id, language: translation.language)
        option_translation.translate_using_google
      end
    end
    translation.instrument.sections.each do |section|
      section_translation = SectionTranslation.new(section_id: section.id, language: translation.language)
      section_translation.translate_using_google
    end
  end
end
