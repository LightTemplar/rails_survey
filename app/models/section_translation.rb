# == Schema Information
#
# Table name: section_translations
#
#  id                        :integer          not null, primary key
#  section_id                :integer
#  language                  :string(255)
#  text                      :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  section_changed           :boolean          default(FALSE)
#  instrument_translation_id :integer
#

class SectionTranslation < ActiveRecord::Base
  include GoogleTranslatable
  belongs_to :section
  belongs_to :instrument_translation
  before_save :touch_section
  validates :text, presence: true, allow_blank: false

  def touch_section
    section.touch if section && changed?
  end

  def translate_using_google
    text_translation = translation_client.translate sanitize_text(section.title), to: language unless section.title.blank?
    self.text = text_translation.text if text_translation
    save
  end
end
