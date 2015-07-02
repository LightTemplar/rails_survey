# == Schema Information
#
# Table name: unit_scores
#
#  id                              :integer          not null, primary key
#  survey_score_id                 :integer
#  unit_id                         :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  value                           :integer
#  variable_id                     :integer
#  center_section_sub_section_name :string(255)
#  center_section_name             :string(255)
#

class UnitScore < ActiveRecord::Base
  attr_accessible :survey_score_id, :unit_id, :value, :variable_id, :center_section_sub_section_name, :center_section_name
  belongs_to :survey_score
  belongs_to :unit
  belongs_to :variable
  
  def score_weight_product
    value * unit.weight
  end
  
  def unit_weights_sum
    scores = UnitScore.where(center_section_sub_section_name: center_section_sub_section_name)
    sum = 0
    scores.each do |score|
      sum += score.unit.weight
    end
    sum
  end
  
  def score_weight_product_sum
    scores = UnitScore.where(center_section_sub_section_name: center_section_sub_section_name)
    sum = 0
    scores.each do |score|
      sum += score.score_weight_product
    end
    sum
  end
  
  def sub_section_score
    (score_weight_product_sum.to_f / unit_weights_sum.to_f).round(2)
  end
  
  def section_score
    scores = UnitScore.where(center_section_name: center_section_name)
    weighted_score_product_sum = scores.inject(0) {|weighted_score_product_sum, score| weighted_score_product_sum += score.score_weight_product}
    unit_weights_sum = scores.inject(0) {|unit_weights_sum, score| unit_weights_sum += score.unit.weight}
    (weighted_score_product_sum.to_f / unit_weights_sum.to_f).round(2)
  end
  
end
