# == Schema Information
#
# Table name: task_option_sets
#
#  id            :bigint           not null, primary key
#  task_id       :integer
#  option_set_id :integer
#  position      :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TaskOptionSet < ApplicationRecord
  belongs_to :task
  belongs_to :option_set
  validates :task_id, presence: true, allow_blank: false
  validates :option_set_id, presence: true, allow_blank: false
  validates :option_set_id, uniqueness: { scope: :task_id,
                                          message: 'should have one record per task' }
  acts_as_paranoid
end
