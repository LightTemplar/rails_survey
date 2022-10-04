class AddFollowUp < ActiveRecord::Migration[4.2]
  def change
    remove_column :questions, :following_up_question_identifier, :string
    remove_column :questions, :follow_up_position, :integer
    remove_column :options, :next_question, :string
    create_table :follow_up_questions do |t|
      t.string :question_identifier
      t.string :following_up_question_identifier
      t.integer :position
      t.integer :instrument_question_id
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
