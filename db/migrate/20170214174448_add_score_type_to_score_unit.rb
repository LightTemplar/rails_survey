class AddScoreTypeToScoreUnit < ActiveRecord::Migration
  def change
    add_column :score_units, :score_type, :integer
  end
end
