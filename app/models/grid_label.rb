# == Schema Information
#
# Table name: grid_labels
#
#  id         :integer          not null, primary key
#  label      :text
#  grid_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class GridLabel < ActiveRecord::Base
  belongs_to :grid
  validates :label, presence: true, allow_blank: false
  acts_as_paranoid
end
