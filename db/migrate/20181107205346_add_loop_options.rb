class AddLoopOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :loop_questions, :option_indices, :string
  end
end
