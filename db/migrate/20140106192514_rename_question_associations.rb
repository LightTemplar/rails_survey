class RenameQuestionAssociations < ActiveRecord::Migration[4.2]
  def change
    rename_table :question_association, :question_associations
  end
end
