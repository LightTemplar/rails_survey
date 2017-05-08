# == Schema Information
#
# Table name: option_translations
#
#  id                        :integer          not null, primary key
#  option_id                 :integer
#  text                      :text
#  language                  :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  option_changed            :boolean          default(FALSE)
#  instrument_translation_id :integer
#

class OptionTranslation < ActiveRecord::Base
  include GoogleTranslatable
  belongs_to :option
  before_save :touch_option
  validates :text, presence: true, allow_blank: false

  def touch_option
    option.touch if option && changed?
  end

  def translate_using_google
    text_translation = translation_client.translate sanitize_text(option.text), to: language unless option.text.blank?
    self.text = text_translation.text if text_translation
    save
  end
end
