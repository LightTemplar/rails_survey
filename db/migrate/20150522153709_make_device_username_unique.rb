class MakeDeviceUsernameUnique < ActiveRecord::Migration[4.2]
  def change
    change_column :device_users, :username, :string, null: false, unique: true
  end
end
