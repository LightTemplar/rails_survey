class AddRegExValidiatonMessageToQuestionTranslation < ActiveRecord::Migration[4.2]
  def change
    add_column :question_translations, :reg_ex_validation_message, :string
  end
end
