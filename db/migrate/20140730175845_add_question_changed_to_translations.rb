class AddQuestionChangedToTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :question_translations, :question_changed, :boolean, default: false
    add_column :option_translations, :option_changed, :boolean, default: false
  end
end
