class CreateBackTranslations < ActiveRecord::Migration
  def change
    create_table :back_translations do |t|
      t.text :text
      t.string :language
      t.integer :backtranslatable_id
      t.string  :backtranslatable_type
      t.timestamps null: false
    end
    add_index :back_translations, [:backtranslatable_id, :backtranslatable_type, :language], unique: true, name: 'backtranslatable_index'
  end
end
