class AddIdToQuestionAssociations < ActiveRecord::Migration[4.2]
  def change
    add_column :question_associations, :question_id, :integer
  end
end
