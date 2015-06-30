class AddNextUnitIdToVariable < ActiveRecord::Migration
  def change
    add_column :variables, :next_unit_name, :string
  end
end
