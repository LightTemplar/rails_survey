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
  attr_accessible :device_id, :device_user_id
  belongs_to :device
  belongs_to :device_user
end