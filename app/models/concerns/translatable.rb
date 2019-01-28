module Translatable
  extend ActiveSupport::Concern

  def translation_for(language)
    translations.find_by_language(language)
  end

  def translated_for(language, field)
    translations.find_by_language(language).send(field) if translation_for language
  end

  def add_or_update_translation_for(translated_text, field, it)
    return if translated_text.blank?
    translated = it.translation_for_child(self)
    translated.send("#{field}=".to_sym, translated_text)
    translated.save
  end
end
