# == Schema Information
#
# Table name: option_translations
#
#  id         :integer          not null, primary key
#  option_id  :integer
#  text       :text
#  language   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class OptionTranslation < ActiveRecord::Base
  attr_accessible :text, :language
  belongs_to :option

  validates :text, presence: true, allow_blank: false
end
