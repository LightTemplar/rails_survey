class AddWeightToUnit < ActiveRecord::Migration
  def change
    add_column :units, :weight, :integer
  end
end
