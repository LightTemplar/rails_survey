class AddVariableToUnitScore < ActiveRecord::Migration
  def change
    add_column :unit_scores, :variable_id, :integer
  end
end
