class AddSameDisplayToLoopQuestion < ActiveRecord::Migration
  def change
    add_column :loop_questions, :same_display, :boolean, default: false
  end
end
