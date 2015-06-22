class ModifyScores < ActiveRecord::Migration
  def change
    remove_column :scores, :name
    remove_column :scores, :value
    add_column :scores, :survey_id, :integer
    rename_column :variables, :reference_score_name, :reference_unit_name
    
    create_table :units do |t|
      t.string :name
      t.integer :value

      t.timestamps
    end
    
    rename_column :variables, :score_id, :unit_id
    
    create_table :score_units do |t|
      t.integer :score_id
      t.integer :unit_id
      
      t.timestamps
    end
    
  end
end