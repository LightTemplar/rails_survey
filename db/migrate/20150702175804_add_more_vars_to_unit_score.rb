class AddMoreVarsToUnitScore < ActiveRecord::Migration
  def change
    add_column :unit_scores, :center_section_sub_section_name, :string
    add_column :unit_scores, :center_section_name, :string
  end
end
