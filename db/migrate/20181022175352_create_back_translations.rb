class CreateBackTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :back_translations do |t|
      t.text :text
      t.string :language
      t.integer :backtranslatable_id
      t.string  :backtranslatable_type
      t.timestamps null: false
    end
    add_index :back_translations, %i[backtranslatable_id backtranslatable_type language], unique: true, name: 'backtranslatable_index'
  end
end
