class AddInstructionsToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :instructions, :text
  end
end
