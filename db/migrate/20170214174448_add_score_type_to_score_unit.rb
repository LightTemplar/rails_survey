class AddScoreTypeToScoreUnit < ActiveRecord::Migration
  def change
    add_column :score_units, :score_type, :integer
    add_column :score_units, :score_per_selection, :float
  end
end
