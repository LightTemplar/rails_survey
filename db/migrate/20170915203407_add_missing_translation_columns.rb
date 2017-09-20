class AddMissingTranslationColumns < ActiveRecord::Migration
  def change
    add_column :option_translations, :instrument_translation_id, :integer unless column_exists?(:option_translations, :instrument_translation_id)
    add_column :question_translations, :instrument_translation_id, :integer unless column_exists?(:question_translations, :instrument_translation_id)
    add_column :section_translations, :instrument_translation_id, :integer unless column_exists?(:section_translations, :instrument_translation_id)
  end
end
