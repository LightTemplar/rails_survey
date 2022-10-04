class AddParentIdentifierToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :parent_identifier, :string
    remove_column :questions, :instrument_id
    remove_column :questions, :reg_ex_validation
    remove_column :questions, :number_in_instrument
    remove_column :questions, :reg_ex_validation_message
    remove_column :questions, :instructions
    remove_column :questions, :child_update_count
    remove_column :questions, :grid_id
    remove_column :questions, :number_in_grid
    remove_column :questions, :section_id
    remove_column :questions, :instrument_version_number
  end
end
