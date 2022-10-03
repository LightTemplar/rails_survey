# == Schema Information
#
# Table name: tasks
#
#  id         :bigint           not null, primary key
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Task < ApplicationRecord
  has_many :task_option_sets, dependent: :destroy
  has_many :questions, dependent: :nullify
  acts_as_paranoid
end
