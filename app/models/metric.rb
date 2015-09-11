# == Schema Information
#
# Table name: metrics
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  name          :string(255)
#  expected      :integer
#  key_name      :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Metric < ActiveRecord::Base
  belongs_to :instrument
  validates_uniqueness_of :key_name, scope: :instrument_id
end
