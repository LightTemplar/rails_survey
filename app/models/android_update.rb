# == Schema Information
#
# Table name: android_updates
#
#  id                      :integer          not null, primary key
#  version                 :integer
#  created_at              :datetime
#  updated_at              :datetime
#  apk_update_file_name    :string(255)
#  apk_update_content_type :string(255)
#  apk_update_file_size    :integer
#  apk_update_updated_at   :datetime
#  name                    :string(255)
#

class AndroidUpdate < ActiveRecord::Base
  default_scope { order('version DESC') }
  has_attached_file :apk_update, url: '/:attachment/:id/:basename.:extension', path: 'updates/:attachment/:id/:basename.:extension'
  # octet-stream validation is for a binary file.
  validates_attachment_content_type :apk_update, content_type: ['application/octet-stream']

  def self.latest_version
    AndroidUpdate.first
  end
end
