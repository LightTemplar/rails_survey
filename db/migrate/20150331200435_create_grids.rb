class CreateGrids < ActiveRecord::Migration[4.2]
  def change
    drop_table :grids if table_exists?(:grids)
    create_table :grids do |t|
      t.integer :instrument_id
      t.string :question_type
      t.string :name
      t.text :option_texts

      t.timestamps
    end
    add_column :questions, :grid_id, :integer unless column_exists?(:questions, :grid_id)
  end
end
