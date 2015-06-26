# == Schema Information
#
# Table name: score_sections
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ScoreSection < ActiveRecord::Base
  attr_accessible :name
  has_many :score_sub_sections, dependent: :destroy
end
