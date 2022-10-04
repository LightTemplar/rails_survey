class CreateMultipleSkips < ActiveRecord::Migration[4.2]
  def change
    create_table :multiple_skips do |t|
      t.string :question_identifier
      t.string :option_identifier
      t.string :skip_question_identifier
      t.integer :instrument_question_id
      t.datetime :deleted_at
      t.timestamps null: false
    end
    add_column :next_questions, :deleted_at, :datetime
  end
end
