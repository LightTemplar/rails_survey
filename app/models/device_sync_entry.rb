# == Schema Information
#
# Table name: device_sync_entries
#
#  id                     :integer          not null, primary key
#  latitude               :string(255)
#  longitude              :string(255)
#  num_complete_surveys   :integer
#  current_language       :string(255)
#  current_version_code   :string(255)
#  instrument_versions    :text
#  created_at             :datetime
#  updated_at             :datetime
#  device_uuid            :string(255)
#  api_key                :string(255)
#  timezone               :string(255)
#  current_version_name   :string(255)
#  os_build_number        :string(255)
#  project_id             :integer
#  num_incomplete_surveys :integer
#

class DeviceSyncEntry < ActiveRecord::Base
  belongs_to :device, foreign_key: :identifier, primary_key: :device_uuid
  belongs_to :project

  def instrument_versions
    JSON.parse(read_attribute(:instrument_versions)) unless read_attribute(:instrument_versions).nil?
  end
end