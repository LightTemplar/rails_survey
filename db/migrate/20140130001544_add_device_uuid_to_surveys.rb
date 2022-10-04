class AddDeviceUuidToSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :device_uuid, :string
  end
end
