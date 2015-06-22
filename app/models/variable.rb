# == Schema Information
#
# Table name: variables
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  value               :integer
#  next_variable       :string(255)
#  reference_unit_name :string(255)
#  unit_id             :integer
#  created_at          :datetime
#  updated_at          :datetime
#  result              :string(255)
#

class Variable < ActiveRecord::Base
  attr_accessible :name, :value, :next_variable, :reference_unit_name, :unit_id, :result
  belongs_to :unit
end
