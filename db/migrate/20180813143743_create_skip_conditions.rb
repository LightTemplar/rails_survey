class CreateSkipConditions < ActiveRecord::Migration[4.2]
  def change
    create_table :condition_skips do |t|
      t.integer :instrument_question_id
      t.string :question_identifier
      t.string :condition_question_identifier
      t.string :condition_option_identifier
      t.string :option_identifier
      t.string :condition
      t.string :next_question_identifier
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
