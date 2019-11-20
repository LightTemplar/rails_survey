# frozen_string_literal: true

# == Schema Information
#
# Table name: device_users
#
#  id              :integer          not null, primary key
#  username        :string           not null
#  name            :string
#  password_digest :string
#  active          :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

class DeviceUser < ApplicationRecord
  has_secure_password
  has_many :device_device_users
  has_many :devices, through: :device_device_users
  has_many :project_device_users
  has_many :projects, through: :project_device_users
  has_one :api_key, dependent: :destroy
  after_create :generate_api_key
  validates :username, presence: true, uniqueness: true, allow_blank: false
  validates :name, presence: true
  validates :password_digest, presence: true

  private

  def generate_api_key
    ApiKey.create!(device_user_id: id) unless api_key
  end
end
