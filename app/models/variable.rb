# == Schema Information
#
# Table name: variables
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  value          :integer
#  next_variable  :string(255)
#  unit_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  result         :string(255)
#  next_unit_name :string(255)
#

class Variable < ActiveRecord::Base
  attr_accessible :name, :value, :next_variable, :unit_id, :result, :next_unit_name
  belongs_to :unit
  has_many :unit_scores
  validates :name, presence: true, :uniqueness => {:scope => [:value, :result, :unit_id]}
  validates :value, presence: true
  validates :result, presence: true
  
  def next_variables
    next_unit = Unit.find_by_name(next_unit_name)
    next_unit.variables.where('name = ?', next_variable) if next_unit
  end

end