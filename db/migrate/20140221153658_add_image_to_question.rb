class AddImageToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :question_id, :integer
  end
end
