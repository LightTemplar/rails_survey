class CreateScoreSubSections < ActiveRecord::Migration
  def change
    create_table :score_sub_sections do |t|
      t.string :name
      t.integer :score_section_id

      t.timestamps
    end
    add_column :scores, :score_sub_section_id, :integer
  end
end
