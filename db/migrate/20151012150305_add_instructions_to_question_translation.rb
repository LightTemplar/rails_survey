class AddInstructionsToQuestionTranslation < ActiveRecord::Migration[4.2]
  def change
    add_column :question_translations, :instructions, :text
  end
end
