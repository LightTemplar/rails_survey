class AddCollageToOption < ActiveRecord::Migration[5.2]
  def change
    remove_column :option_in_option_sets, :has_image, :boolean
    remove_column :options, :text_one, :string
    remove_column :options, :text_two, :string
    remove_column :option_translations, :text_one, :string
    remove_column :option_translations, :text_two, :string
    remove_column :questions, :has_question_image, :boolean
    remove_column :questions, :question_image_height, :integer
    add_column :option_in_option_sets, :collage_id, :integer
  end
end
