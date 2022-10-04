class CreateOptionInOptionSets < ActiveRecord::Migration[4.2]
  def change
    create_table :option_in_option_sets do |t|
      t.integer :option_id, null: false
      t.integer :option_set_id, null: false
      t.integer :number_in_question, null: false
      t.datetime :deleted_at
      t.timestamps null: false
    end
    add_column :option_sets, :deleted_at, :datetime
  end
end
