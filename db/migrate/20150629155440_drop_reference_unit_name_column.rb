class DropReferenceUnitNameColumn < ActiveRecord::Migration
  def change
    remove_column :variables, :reference_unit_name
  end
end
