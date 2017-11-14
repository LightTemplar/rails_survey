# == Schema Information
#
# Table name: display_groups
#
#  id                          :integer          not null, primary key
#  title                       :string
#  randomized_display_group_id :integer
#  position                    :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class DisplayGroup < ActiveRecord::Base
  belongs_to :randomized_display_group, touch: true
  has_many :questions
end
