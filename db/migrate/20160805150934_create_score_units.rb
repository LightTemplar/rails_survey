class CreateScoreUnits < ActiveRecord::Migration
  def change
    create_table :score_units do |t|
      t.integer :score_scheme_id
      t.string :question_type
      t.float :min
      t.float :max
      t.float :weight

      t.timestamps
    end
  end
end
