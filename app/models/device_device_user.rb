# == Schema Information
#
# Table name: device_device_users
#
#  id             :integer          not null, primary key
#  device_id      :integer
#  device_user_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class DeviceDeviceUser < ActiveRecord::Base
  belongs_to :device
  belongs_to :device_user
end