class AddValidationTypes < ActiveRecord::Migration[4.2]
  def change
    rename_column :validations, :reg_ex_validation, :validation_text
    rename_column :validations, :reg_ex_validation_message, :validation_message
    add_column :validations, :validation_type, :string
    add_column :validations, :response_identifier, :string
    add_column :validations, :relational_operator, :string
    remove_column :questions, :sum_of_parts
    remove_column :instrument_questions, :sum_of_parts_identifier
  end
end
