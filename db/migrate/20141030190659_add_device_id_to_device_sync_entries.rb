class AddDeviceIdToDeviceSyncEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :device_sync_entries, :device_id, :integer
  end
end
