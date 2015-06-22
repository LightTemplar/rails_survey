# == Schema Information
#
# Table name: units
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  value      :integer
#  created_at :datetime
#  updated_at :datetime
#

class Unit < ActiveRecord::Base
  attr_accessible :name, :value
  has_many :variables
  has_many :score_units
end
