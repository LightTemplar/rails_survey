class ChangeDeviceIdToDeviceIdentifierInSurveys < ActiveRecord::Migration[4.2]
  def change
    rename_column :surveys, :device_id, :device_identifier
  end
end
