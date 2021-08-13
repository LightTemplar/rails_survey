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
  has_one :api_key
  has_many :device_device_users
  has_many :devices, through: :device_device_users
  has_many :project_device_users
  has_many :projects, through: :project_device_users
  has_many :published_instruments, through: :projects
  has_many :surveys
  has_many :ongoing_surveys, -> { ongoing }, class_name: 'Survey'
  has_many :completed_surveys, -> { finished }, class_name: 'Survey'
  has_many :survey_scores, through: :completed_surveys

  validates :username, presence: true, uniqueness: true, allow_blank: false
  validates :name, presence: true
  validates :password_digest, presence: true

  def self.from_token_payload(payload)
    find payload['sub']
  end

  def self.from_token_request(request)
    puts request.params
    user_name = request.params['auth'] && request.params['auth']['username']
    find_by username: user_name
  end
end
