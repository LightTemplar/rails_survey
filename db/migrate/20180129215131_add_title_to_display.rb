class AddTitleToDisplay < ActiveRecord::Migration
  def change
    add_column :displays, :title, :string
  end
end
