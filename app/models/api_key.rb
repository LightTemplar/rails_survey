# frozen_string_literal: true

# == Schema Information
#
# Table name: api_keys
#
#  id             :integer          not null, primary key
#  access_token   :string
#  created_at     :datetime
#  updated_at     :datetime
#  device_user_id :integer
#

class ApiKey < ApplicationRecord
  before_create :generate_access_token
  belongs_to :device_user

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
