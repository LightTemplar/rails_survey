class AddDeviceUserToApiKey < ActiveRecord::Migration
  def change
    add_column :api_keys, :device_user_id, :integer
  end
end
