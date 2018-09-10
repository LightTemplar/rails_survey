# == Schema Information
#
# Table name: section_translations
#
#  id                        :integer          not null, primary key
#  section_id                :integer
#  language                  :string
#  text                      :string
#  created_at                :datetime
#  updated_at                :datetime
#  section_changed           :boolean          default(FALSE)
#  instrument_translation_id :integer
#

class SectionTranslation < ActiveRecord::Base
  belongs_to :section, touch: true
  validates :text, presence: true, allow_blank: false
  validates :section_id, presence: true, allow_blank: false
  validates :language, presence: true, allow_blank: false
end
