# == Schema Information
#
# Table name: device_sync_entries
#
#  id                     :integer          not null, primary key
#  latitude               :string
#  longitude              :string
#  num_complete_surveys   :integer
#  current_language       :string
#  current_version_code   :string
#  instrument_versions    :text
#  created_at             :datetime
#  updated_at             :datetime
#  device_uuid            :string
#  api_key                :string
#  timezone               :string
#  current_version_name   :string
#  os_build_number        :string
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
