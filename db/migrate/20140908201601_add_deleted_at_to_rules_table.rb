class AddDeletedAtToRulesTable < ActiveRecord::Migration[4.2]
  def change
    add_column :rules, :deleted_at, :time
  end
end
