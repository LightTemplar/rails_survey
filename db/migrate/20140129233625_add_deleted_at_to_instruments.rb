class AddDeletedAtToInstruments < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :deleted_at, :datetime
  end
end
