# frozen_string_literal: true

class AddDeviceUserIdToSurvey < ActiveRecord::Migration[5.1]
  def change
    add_column :surveys, :device_user_id, :integer
    add_column :surveys, :completed, :boolean, default: false
  end
end
