# == Schema Information
#
# Table name: display_translations
#
#  id         :integer          not null, primary key
#  display_id :integer
#  text       :text
#  language   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DisplayTranslation < ActiveRecord::Base
  belongs_to :display, touch: true
  validates :text, presence: true, allow_blank: false
  validates :language, presence: true, allow_blank: false
  validates :display_id, presence: true, allow_blank: false
end
