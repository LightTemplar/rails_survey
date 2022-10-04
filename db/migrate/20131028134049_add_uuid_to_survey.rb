class AddUuidToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :uuid, :string, unique: true
    add_index(:surveys, :uuid)
  end
end
