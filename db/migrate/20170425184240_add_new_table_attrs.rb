class AddNewTableAttrs < ActiveRecord::Migration
  def change
    remove_column :grid_labels, :option_id, :integer
    remove_column :questions, :first_in_grid, :boolean
    add_column :questions, :number_in_grid, :integer
    add_column :grids, :instructions, :text
    add_column :grids, :deleted_at, :datetime
    add_column :grid_labels, :deleted_at, :datetime
  end
end
