# == Schema Information
#
# Table name: displays
#
#  id            :integer          not null, primary key
#  mode          :string
#  position      :string
#  instrument_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Display < ActiveRecord::Base
  belongs_to :instrument
  has_many :instrument_questions
end
