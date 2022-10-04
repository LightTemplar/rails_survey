class CreateGridTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :grid_translations do |t|
      t.integer :grid_id
      t.integer :instrument_translation_id
      t.string :name
      t.text :instructions
      t.timestamps
    end
    create_table :grid_label_translations do |t|
      t.integer :grid_label_id
      t.integer :instrument_translation_id
      t.text :label
      t.timestamps
    end
    add_column :surveys, :language, :string
  end
end
