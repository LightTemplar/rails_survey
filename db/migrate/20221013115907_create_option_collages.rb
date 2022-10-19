class CreateOptionCollages < ActiveRecord::Migration[5.2]
  def change
    create_table :option_collages do |t|
      t.integer :option_in_option_set_id
      t.integer :collage_id
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
    create_table :question_collages do |t|
      t.integer :question_id
      t.integer :collage_id
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
