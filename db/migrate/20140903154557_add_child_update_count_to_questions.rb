class AddChildUpdateCountToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :child_update_count, :integer, default: 0
  end
end
