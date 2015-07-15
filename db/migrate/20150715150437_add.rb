class Add < ActiveRecord::Migration
  def change
    add_column :surveys, :device_label, :string
  end
end
