class AddRegExValidationToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :reg_ex_validation, :string
  end
end
