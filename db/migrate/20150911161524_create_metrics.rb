class CreateMetrics < ActiveRecord::Migration[4.2]
  def change
    create_table :metrics do |t|
      t.integer :instrument_id
      t.string :name
      t.integer :expected
      t.string :key_name

      t.timestamps
    end
  end
end
