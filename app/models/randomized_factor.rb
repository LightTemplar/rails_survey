# == Schema Information
#
# Table name: randomized_factors
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  title         :string
#  created_at    :datetime
#  updated_at    :datetime
#

class RandomizedFactor < ActiveRecord::Base
  belongs_to :instrument, touch: true
  has_many :randomized_options, dependent: :destroy
  validates :instrument_id, presence: true
  validates :title, presence: true
end
