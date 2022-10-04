class AddDeviceIdToSurveys < ActiveRecord::Migration[4.2]
  def change
    remove_column :surveys, :device_identifier
    add_column :surveys, :device_id, :integer
  end
end
