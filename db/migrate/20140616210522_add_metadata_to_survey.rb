class AddMetadataToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :metadata, :text
  end
end
