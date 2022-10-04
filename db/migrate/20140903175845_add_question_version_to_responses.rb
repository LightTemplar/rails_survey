class AddQuestionVersionToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :question_version, :integer, default: -1
  end
end
