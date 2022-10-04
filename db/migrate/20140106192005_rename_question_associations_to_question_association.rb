class RenameQuestionAssociationsToQuestionAssociation < ActiveRecord::Migration[4.2]
  def change
    rename_table :question_associations, :question_association
  end
end
