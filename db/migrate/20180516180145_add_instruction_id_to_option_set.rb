class AddInstructionIdToOptionSet < ActiveRecord::Migration
  def change
    add_column :option_sets, :instruction_id, :integer
    create_table :display_instructions do |t|
      t.integer :display_id
      t.integer :instruction_id
      t.integer :position
      t.timestamp :deleted_at
      t.timestamps null: false
    end
  end
end
