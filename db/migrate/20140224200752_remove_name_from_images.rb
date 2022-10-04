class RemoveNameFromImages < ActiveRecord::Migration[4.2]
  def change
    remove_column :images, :name
  end
end
