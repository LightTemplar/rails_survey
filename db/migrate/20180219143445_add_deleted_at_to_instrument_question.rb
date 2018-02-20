class AddDeletedAtToInstrumentQuestion < ActiveRecord::Migration
  def change
    add_column :instrument_questions, :deleted_at, :datetime
    add_index :instrument_questions, :deleted_at
    add_column :displays, :deleted_at, :datetime
    add_index :displays, :deleted_at
    add_column :instructions, :deleted_at, :datetime
    add_index :instructions, :deleted_at
    remove_column :rules, :instrument_id
    create_table :instrument_rules do |t|
      t.integer :instrument_id
      t.integer :rule_id
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
