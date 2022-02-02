class AddImageAligment < ActiveRecord::Migration[5.2]
  def change
    add_column :option_sets, :align_image_vertical, :boolean, default: true
  end
end
