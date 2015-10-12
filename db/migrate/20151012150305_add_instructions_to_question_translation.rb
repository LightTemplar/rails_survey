class AddInstructionsToQuestionTranslation < ActiveRecord::Migration
  def change
    add_column :question_translations, :instructions, :text
  end
end
