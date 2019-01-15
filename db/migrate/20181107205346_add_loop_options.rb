class AddLoopOptions < ActiveRecord::Migration
  def change
    add_column :loop_questions, :option_indices, :string
  end
end
