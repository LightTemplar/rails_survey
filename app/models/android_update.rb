# frozen_string_literal: true

# == Schema Information
#
# Table name: android_updates
#
#  id         :integer          not null, primary key
#  version    :integer
#  created_at :datetime
#  updated_at :datetime
#  name       :string
#

class AndroidUpdate < ApplicationRecord
  default_scope { order('version DESC') }
  has_one_attached :apk_update
  validates :apk_update, attached: true, content_type: ['application/octet-stream']

  def self.latest_version
    AndroidUpdate.first
  end
end
