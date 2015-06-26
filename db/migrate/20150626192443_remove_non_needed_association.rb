class RemoveNonNeededAssociation < ActiveRecord::Migration
  def change
    remove_column :scores, :score_sub_section_id
  end
end
