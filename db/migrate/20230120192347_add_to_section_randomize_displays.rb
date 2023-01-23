class AddToSectionRandomizeDisplays < ActiveRecord::Migration[5.2]
  def change
    add_column :sections, :randomize_displays, :boolean, default: false
  end
end
