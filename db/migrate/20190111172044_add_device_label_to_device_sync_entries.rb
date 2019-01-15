class AddDeviceLabelToDeviceSyncEntries < ActiveRecord::Migration
  def change
    add_column :device_sync_entries, :device_label, :string
  end
end
