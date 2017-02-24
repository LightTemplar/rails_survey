# == Schema Information
#
# Table name: device_users
#
#  id              :integer          not null, primary key
#  username        :string(255)      not null
#  name            :string(255)
#  password_digest :string(255)
#  active          :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

class DeviceUser < ActiveRecord::Base
  include CacheWarmAble
  include AsJsonAble
  has_secure_password
  has_many :device_device_users
  has_many :devices, through: :device_device_users
  has_many :project_device_users
  has_many :projects, through: :project_device_users
  validates :username, presence: true, uniqueness: true, allow_blank: false
  validates :name, presence: true
  validates :password_digest, presence: true

end