class CreateProjectDeviceUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :project_device_users do |t|
      t.integer :project_id
      t.integer :device_user_id

      t.timestamps
    end
    remove_column :device_users, :project_id
  end
end
