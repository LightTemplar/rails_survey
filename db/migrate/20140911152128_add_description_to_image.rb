class AddDescriptionToImage < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :description, :string
  end
end
