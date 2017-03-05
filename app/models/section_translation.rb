# == Schema Information
#
# Table name: section_translations
#
#  id              :integer          not null, primary key
#  section_id      :integer
#  language        :string(255)
#  text            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  section_changed :boolean          default(FALSE)
#

class SectionTranslation < ActiveRecord::Base
  belongs_to :section
  before_save :touch_section
  validates :text, presence: true, allow_blank: false

  def touch_section
    section.touch if section && changed?
  end
end
