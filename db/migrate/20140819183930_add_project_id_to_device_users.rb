class AddProjectIdToDeviceUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :device_users, :project_id, :integer
  end
end
