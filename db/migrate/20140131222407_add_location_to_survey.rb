class AddLocationToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :latitude, :string
    add_column :surveys, :longitude, :string
  end
end
