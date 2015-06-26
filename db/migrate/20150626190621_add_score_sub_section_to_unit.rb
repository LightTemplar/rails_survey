class AddScoreSubSectionToUnit < ActiveRecord::Migration
  def change
    add_column :units, :score_sub_section_id, :integer
  end
end
