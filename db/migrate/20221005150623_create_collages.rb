class CreateCollages < ActiveRecord::Migration[5.2]
  def change
    create_table :collages do |t|
      t.integer :question_id
      t.string :name
      t.integer :position
      t.datetime :deleted_at
      t.timestamps
    end
    remove_column :diagrams, :question_id, :integer
    add_column :diagrams, :collage_id, :integer
  end
end
