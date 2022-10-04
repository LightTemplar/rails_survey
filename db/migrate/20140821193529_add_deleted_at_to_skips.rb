class AddDeletedAtToSkips < ActiveRecord::Migration[4.2]
  def change
    add_column :skips, :deleted_at, :datetime
    add_index :skips, :deleted_at
  end
end
