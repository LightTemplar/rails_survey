class AddNumberToImage < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :number, :integer
  end
end
