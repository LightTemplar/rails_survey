class AddHasImageToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :has_question_image, :boolean, default: false
    add_column :questions, :question_image_height, :integer, default: 500
  end
end
