class CreateScoreSchemes < ActiveRecord::Migration
  def change
    create_table :score_schemes do |t|
      t.string :instrument_id
      t.string :title

      t.timestamps
    end
  end
end
