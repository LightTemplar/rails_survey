class AddTimezoneToDeviceSyncEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :device_sync_entries, :timezone, :string
  end
end
