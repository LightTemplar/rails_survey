class AddQuestionIdentifierToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :question_identifier, :string
  end
end
