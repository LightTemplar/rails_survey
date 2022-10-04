class AddDeletedAtToOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :options, :deleted_at, :datetime
  end
end
