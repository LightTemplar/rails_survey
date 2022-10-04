class CreateRandomizedOptionTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :randomized_option_translations do |t|
      t.integer :instrument_translation_id
      t.integer :randomized_option_id
      t.text :text
      t.string :language
      t.timestamps null: false
    end
  end
end
