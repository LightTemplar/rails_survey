class CreateBackTranslations < ActiveRecord::Migration
  def change
    create_table :back_translations do |t|
      t.text :text
      t.references :backtranslatable, polymorphic: true, index: { name: 'backtranslatable_index' }
      t.timestamps null: false
    end
  end
end
