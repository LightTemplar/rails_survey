class AddDeletedAtToSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :deleted_at, :datetime
    add_index :surveys, :deleted_at
    add_column :responses, :deleted_at, :datetime
    add_index :responses, :deleted_at
  end
end
