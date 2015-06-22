class AddValueToUnitScore < ActiveRecord::Migration
  def change
    add_column :variables, :result, :string
    remove_column :units, :value
    add_column :score_units, :value, :integer
    rename_table :score_units, :unit_scores
  end
end
