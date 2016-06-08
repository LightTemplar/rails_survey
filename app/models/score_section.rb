# == Schema Information
#
# Table name: score_sections
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  instrument_id :integer
#

class ScoreSection < ActiveRecord::Base
  attr_accessible :name, :instrument_id
  has_many :score_sub_sections, dependent: :destroy
  has_many :units, through: :score_sub_sections
  has_many :variables, through: :units
end