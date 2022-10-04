class AddTitleToDisplay < ActiveRecord::Migration[4.2]
  def change
    add_column :displays, :title, :string
  end
end
