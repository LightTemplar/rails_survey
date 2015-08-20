class CreateDeviceDeviceUsers < ActiveRecord::Migration
  def change
    create_table :device_device_users do |t|
      t.integer :device_id
      t.integer :device_user_id

      t.timestamps
    end
    remove_column :device_users, :device_id
  end
end
