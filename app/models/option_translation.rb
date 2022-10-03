# frozen_string_literal: true

# == Schema Information
#
# Table name: option_translations
#
#  id                        :integer          not null, primary key
#  option_id                 :integer
#  text                      :text
#  language                  :string
#  created_at                :datetime
#  updated_at                :datetime
#  option_changed            :boolean          default(FALSE)
#  instrument_translation_id :integer
#  text_one                  :string
#  text_two                  :string
#

class OptionTranslation < ApplicationRecord
  include GoogleTranslatable
  include Sanitizable
  belongs_to :option, touch: true

  has_many :back_translations, as: :backtranslatable
  has_many :option_set_translations

  validates :language, presence: true, allow_blank: false
  validates :text, presence: true, allow_blank: false
  validates :option_id, presence: true, allow_blank: false, uniqueness: { scope: %i[language text] }

  def translate_using_google
    text_translation = translation_client.translate sanitize_text(option.text), to: language unless option.text.blank?
    self.text = text_translation.text if text_translation
    save
  end
end
