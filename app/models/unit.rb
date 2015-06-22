# == Schema Information
#
# Table name: units
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Unit < ActiveRecord::Base
  attr_accessible :name
  has_many :variables
  has_many :unit_scores
end
