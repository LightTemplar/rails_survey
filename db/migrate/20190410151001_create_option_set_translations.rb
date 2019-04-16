# frozen_string_literal: true

class CreateOptionSetTranslations < ActiveRecord::Migration
  def change
    create_table :option_set_translations do |t|
      t.integer :option_set_id
      t.integer :option_translation_id
      t.timestamps null: false
    end
  end
end
