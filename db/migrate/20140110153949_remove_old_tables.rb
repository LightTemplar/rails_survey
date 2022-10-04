class RemoveOldTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :question_associations
    drop_table :option_associations
  end
end
