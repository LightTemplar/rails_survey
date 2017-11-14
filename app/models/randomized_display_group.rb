# == Schema Information
#
# Table name: randomized_display_groups
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class RandomizedDisplayGroup < ActiveRecord::Base
  belongs_to :instrument, touch: true
  has_many :display_groups, dependent: :destroy
end
