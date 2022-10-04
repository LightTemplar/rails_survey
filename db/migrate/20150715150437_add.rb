class Add < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :device_label, :string
  end
end
