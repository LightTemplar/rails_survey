# == Schema Information
#
# Table name: project_device_users
#
#  id             :integer          not null, primary key
#  project_id     :integer
#  device_user_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class ProjectDeviceUser < ActiveRecord::Base
  belongs_to :project
  belongs_to :device_user
end