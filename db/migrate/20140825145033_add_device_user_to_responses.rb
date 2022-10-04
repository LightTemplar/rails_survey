class AddDeviceUserToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :device_user_id, :integer
  end
end
