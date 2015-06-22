# == Schema Information
#
# Table name: score_units
#
#  id         :integer          not null, primary key
#  score_id   :integer
#  unit_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class ScoreUnit < ActiveRecord::Base
  attr_accessible :score_id, :unit_id
  belongs_to :score
  belongs_to :unit
end
