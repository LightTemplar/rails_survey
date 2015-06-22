class CreateVariables < ActiveRecord::Migration
  def change
    create_table :variables do |t|
      t.string :name
      t.integer :value
      t.string :next_variable
      t.string :reference_score_name
      t.integer :score_id

      t.timestamps
    end
  end
end
