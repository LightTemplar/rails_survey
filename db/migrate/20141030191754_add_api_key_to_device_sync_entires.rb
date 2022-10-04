class AddApiKeyToDeviceSyncEntires < ActiveRecord::Migration[4.2]
  def change
    add_column :device_sync_entries, :api_key, :string
  end
end
