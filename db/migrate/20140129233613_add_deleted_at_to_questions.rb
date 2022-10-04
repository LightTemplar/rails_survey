class AddDeletedAtToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :deleted_at, :datetime
  end
end
