# == Schema Information
#
# Table name: option_translations
#
#  id             :integer          not null, primary key
#  option_id      :integer
#  text           :text
#  language       :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  option_changed :boolean          default(FALSE)
#

class OptionTranslation < ActiveRecord::Base
  include CacheWarmAble
  belongs_to :option
  before_save :touch_option
  validates :text, presence: true, allow_blank: false

  def touch_option
    option.touch if option && changed?
  end
end
