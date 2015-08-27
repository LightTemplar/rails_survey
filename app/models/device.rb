# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  identifier :string(255)
#  created_at :datetime
#  updated_at :datetime
#  label      :string(255)
#
class Device < ActiveRecord::Base
  attr_accessible :identifier, :label
  has_many :surveys
  has_many :project_devices
  has_many :projects, through: :project_devices
  has_many :device_sync_entries, foreign_key: :device_uuid, primary_key: :identifier, dependent: :destroy
  has_many :device_device_users
  has_many :device_users, through: :device_device_users
  validates :identifier, uniqueness: true, presence: true, allow_blank: false

  def danger_zone?(project)
    if device_sync_entries && last_sync_entry(project)
      last_sync_entry(project).updated_at < Settings.danger_zone_days.days.ago
    elsif last_project_survey(project)
      last_project_survey(project).updated_at.to_time < Settings.danger_zone_days.days.ago
    end
  end

  def last_project_survey(project)
    if projects.include?(project)
      project.device_surveys(self).order('updated_at ASC').last
    end
  end

  def last_sync_entry(project)
    device_sync_entries.where(project_id: project.id).order('updated_at ASC').last
  end

  def uptodate?(project)
    if last_sync_entry project
      last_sync_entry(project).num_complete_surveys == 0 && !danger_zone?(project) && last_sync_entry(project).current_version_code == (AndroidUpdate.latest_version.version.to_s if AndroidUpdate.latest_version)
    end
  end

end