class AddDeletedAtToInstrumentQuestion < ActiveRecord::Migration
  def change
    add_column :instrument_questions, :deleted_at, :datetime
    add_index :instrument_questions, :deleted_at
    add_column :displays, :deleted_at, :datetime
    add_index :displays, :deleted_at
    add_column :instructions, :deleted_at, :datetime
    add_index :instructions, :deleted_at
  end
end
