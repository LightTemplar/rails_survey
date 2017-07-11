# == Schema Information
#
# Table name: randomized_options
#
#  id                   :integer          not null, primary key
#  randomized_factor_id :integer
#  text                 :text
#  created_at           :datetime
#  updated_at           :datetime
#

class RandomizedOption < ActiveRecord::Base
  belongs_to :randomized_factor, touch: true
  validates :text, presence: true
  validates :randomized_factor_id, presence: true
end
