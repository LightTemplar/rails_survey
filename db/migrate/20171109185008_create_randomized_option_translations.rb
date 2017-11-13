class CreateRandomizedOptionTranslations < ActiveRecord::Migration
  def change
    create_table :randomized_option_translations do |t|
      t.integer :instrument_translation_id
      t.integer :randomized_option_id
      t.text :text
      t.string :language
      t.timestamps null: false
    end
    create_table :randomized_display_groups do |t|
      t.integer :instrument_id
      t.string :title
      t.timestamps null: false
    end
    create_table :display_groups do |t|
      t.string :title
      t.integer :randomized_display_group_id
      t.integer :position
      t.timestamps null: false
    end
    add_column :questions, :display_group_id, :integer
  end
end
