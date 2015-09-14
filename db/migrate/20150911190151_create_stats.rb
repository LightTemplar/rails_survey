class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :metric_id
      t.string :key_value
      t.integer :count
      t.string :percent

      t.timestamps
    end
  end
end
