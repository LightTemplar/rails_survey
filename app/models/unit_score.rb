# == Schema Information
#
# Table name: unit_scores
#
#  id              :integer          not null, primary key
#  survey_score_id :integer
#  unit_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  value           :integer
#  variable_id     :integer
#

class UnitScore < ActiveRecord::Base
  attr_accessible :survey_score_id, :unit_id, :value, :variable_id
  belongs_to :survey_score
  belongs_to :unit
  belongs_to :variable
  
  def score_weight_product
    value * unit.weight
  end
  
end
