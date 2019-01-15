class AddSectionIdToDisplay < ActiveRecord::Migration
  def change
    add_column :displays, :section_id, :integer
  end
end
