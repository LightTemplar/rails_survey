class AddSectionIdToDisplay < ActiveRecord::Migration[4.2]
  def change
    add_column :displays, :section_id, :integer
  end
end
