class CreateDisplayTranslations < ActiveRecord::Migration
  def change
    create_table :display_translations do |t|
      t.integer :display_id
      t.text :text
      t.string :language
      t.timestamps null: false
    end
    remove_column :displays, :section_title
  end
end
