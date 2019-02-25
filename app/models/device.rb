# frozen_string_literal: true

# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  identifier :string
#  created_at :datetime
#  updated_at :datetime
#  label      :string
#

class Device < ActiveRecord::Base
  has_many :surveys
  has_many :project_devices
  has_many :projects, through: :project_devices
  has_many :device_sync_entries, foreign_key: :device_uuid, primary_key: :identifier, dependent: :destroy
  has_many :device_device_users
  has_many :device_users, through: :device_device_users
  after_create :format_label
  validates :identifier, uniqueness: true, presence: true, allow_blank: false

  def format_label
    update_columns(label: label.downcase.tr(' ', '')) unless label.blank?
  end

  def danger_zone?(project)
    if device_sync_entries && last_sync_entry(project)
      last_sync_entry(project).updated_at < Settings.danger_zone_days.days.ago
    elsif last_project_survey(project)
      last_project_survey(project).updated_at.to_time < Settings.danger_zone_days.days.ago
    end
  end

  def last_project_survey(project)
    project.device_surveys(self).order('updated_at ASC').last if projects.include?(project)
  end

  def last_sync_entry(project)
    device_sync_entries.where(project_id: project.id).order('updated_at ASC').last
  end

  def uptodate?(project)
    if last_sync_entry project
      last_sync_entry(project).num_complete_surveys.zero? && !danger_zone?(project) && last_sync_entry(project).current_version_code == (AndroidUpdate.latest_version.version.to_s if AndroidUpdate.latest_version)
    end
  end

  def pretty_label
    label.downcase.gsub(/\W+/, '_') unless label.blank?
  end
end
