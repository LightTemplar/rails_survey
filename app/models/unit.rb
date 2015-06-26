# == Schema Information
#
# Table name: units
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  weight               :integer
#  score_sub_section_id :integer
#

class Unit < ActiveRecord::Base
  attr_accessible :name, :weight, :score_sub_section_id
  has_many :variables, dependent: :destroy
  has_many :unit_scores, dependent: :destroy
  belongs_to :score_sub_section
end
