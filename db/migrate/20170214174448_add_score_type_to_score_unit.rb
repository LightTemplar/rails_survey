class AddScoreTypeToScoreUnit < ActiveRecord::Migration[4.2]
  def change
    add_column :score_units, :score_type, :integer
    add_column :score_units, :score_per_selection, :float
  end
end
