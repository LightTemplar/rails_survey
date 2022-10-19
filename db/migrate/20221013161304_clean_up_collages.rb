class CleanUpCollages < ActiveRecord::Migration[5.2]
  def change
    remove_column :collages, :question_id, :integer
    remove_column :collages, :position, :integer
    remove_column :option_in_option_sets, :collage_id, :integer
    add_index :question_collages, :question_id
    add_index :question_collages, :collage_id
    add_index :option_collages, :option_in_option_set_id
    add_index :option_collages, :collage_id
    add_index :diagrams, :option_id
    add_index :diagrams, :collage_id
  end
end
