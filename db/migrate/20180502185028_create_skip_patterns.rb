class CreateSkipPatterns < ActiveRecord::Migration
  def change
    create_table :skip_patterns do |t|
      t.string :option_identifier
      t.string :question_identifier
      t.string :next_question_identifier
      t.timestamps null: false
    end
  end
end
