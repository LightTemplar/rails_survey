# == Schema Information
#
# Table name: unit_scores
#
#  id         :integer          not null, primary key
#  score_id   :integer
#  unit_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  value      :integer
#

class UnitScore < ActiveRecord::Base
  attr_accessible :score_id, :unit_id, :value
  belongs_to :score
  belongs_to :unit
end
