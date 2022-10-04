class CreateScores < ActiveRecord::Migration[4.2]
  def change
    create_table :scores do |t|
      t.integer :survey_id
      t.integer :score_scheme_id
      t.float :score_sum
      t.timestamps
    end

    create_table :raw_scores do |t|
      t.integer :score_unit_id
      t.integer :score_id
      t.float :value
      t.timestamps
    end
  end
end
