# == Schema Information
#
# Table name: instrument_translations
#
#  id               :integer          not null, primary key
#  instrument_id    :integer
#  language         :string(255)
#  alignment        :string(255)
#  title            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  critical_message :text
#

class InstrumentTranslation < ActiveRecord::Base
  include Alignable
  include LanguageAssignable
  include GoogleTranslatable
  belongs_to :instrument
  before_save :touch_instrument

  def touch_instrument
    instrument.touch if instrument && changed?
  end

  def translate_using_google
    title_translation = translation_client.translate sanitize_text(instrument.title), to: language unless instrument.title.blank?
    self.title = title_translation.text if title_translation
    critical_message_translation = translation_client.translate sanitize_text(instrument.critical_message), to: language unless instrument.critical_message.blank?
    self.critical_message = critical_message_translation.text if critical_message_translation
    save
  end
end
