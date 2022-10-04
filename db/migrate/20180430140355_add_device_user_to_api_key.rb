class AddDeviceUserToApiKey < ActiveRecord::Migration[4.2]
  def change
    add_column :api_keys, :device_user_id, :integer
  end
end
