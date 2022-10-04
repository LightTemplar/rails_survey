class AddPositionToGridLabel < ActiveRecord::Migration[4.2]
  def change
    add_column :grid_labels, :position, :integer
  end
end
