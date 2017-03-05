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
  belongs_to :instrument
  before_save :touch_instrument

  def touch_instrument
    instrument.touch if instrument && changed?
  end
end
