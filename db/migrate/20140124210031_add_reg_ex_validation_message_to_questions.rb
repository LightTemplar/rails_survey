class AddRegExValidationMessageToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :reg_ex_validation_message, :string
  end
end
