class AddSameDisplayToLoopQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :loop_questions, :same_display, :boolean, default: false
  end
end
