class CreateRandomizedOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :randomized_factors do |t|
      t.integer :instrument_id
      t.string :title
      t.timestamps
    end
    create_table :randomized_options do |t|
      t.integer :randomized_factor_id
      t.text :text
      t.timestamps
    end
    create_table :question_randomized_factors do |t|
      t.integer :question_id
      t.integer :randomized_factor_id
      t.integer :position
      t.timestamps
    end
    add_column :responses, :randomized_data, :text
  end
end
