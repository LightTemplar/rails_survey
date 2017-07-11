class AddPositionToGridLabel < ActiveRecord::Migration
  def change
    add_column :grid_labels, :position, :integer
  end
end
