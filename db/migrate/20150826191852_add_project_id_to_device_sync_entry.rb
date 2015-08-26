class AddProjectIdToDeviceSyncEntry < ActiveRecord::Migration
  def change
    add_column :device_sync_entries, :os_build_number, :string
    add_column :device_sync_entries, :project_id, :integer
    add_column :device_sync_entries, :num_incomplete_surveys, :integer
    rename_column :device_sync_entries, :num_surveys, :num_complete_surveys
  end
end
