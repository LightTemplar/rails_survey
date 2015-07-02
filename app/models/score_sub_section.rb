# == Schema Information
#
# Table name: score_sub_sections
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  score_section_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class ScoreSubSection < ActiveRecord::Base
  attr_accessible :name, :score_section_id
  has_many :units, dependent: :destroy
  has_many :unit_scores, through: :units
  belongs_to :score_section
  
  def units_score_weights_sum
    units.sum(:weight)
  end
  
  def units_score_weight_products_sum
    sum = 0
    unit_scores.each do |unit_score|
      sum += unit_score.score_weight_product
    end
    sum
  end
  
  def score
    units_score_weight_products_sum /  units_score_weights_sum
  end
  
end
