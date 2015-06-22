# == Schema Information
#
# Table name: scores
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  survey_id  :integer
#

class Score < ActiveRecord::Base
  attr_accessible :survey_id
  has_many :score_units, dependent: :destroy
  has_many :units, through: :score_units
end
