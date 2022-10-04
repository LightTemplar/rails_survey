class RemoveDeviceIdFromResponses < ActiveRecord::Migration[4.2]
  def change
    remove_column :responses, :device_id
  end
end
