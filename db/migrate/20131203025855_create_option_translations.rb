class CreateOptionTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :option_translations do |t|
      t.integer :option_id
      t.string :text
      t.string :language

      t.timestamps
    end
  end
end
