class AddDeletedAtToSections < ActiveRecord::Migration[4.2]
  def change
    add_column :sections, :deleted_at, :datetime
    add_index :sections, :deleted_at
  end
end
