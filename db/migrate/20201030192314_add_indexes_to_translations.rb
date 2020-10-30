# frozen_string_literal: true

class AddIndexesToTranslations < ActiveRecord::Migration[5.1]
  def change
    add_index :option_translations, :option_id
    add_index :option_translations, :language
    add_index :option_set_translations, :option_set_id
    add_index :option_set_translations, :option_translation_id
    add_index :instruction_translations, :instruction_id
    add_index :instruction_translations, :language
    add_index :question_translations, :question_id
    add_index :question_translations, :language
  end
end
