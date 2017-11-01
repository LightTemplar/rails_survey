class AddSets < ActiveRecord::Migration
  def change
    create_table :question_sets do |t|
      t.string :title
      t.timestamps
    end
    create_table :option_sets do |t|
      t.string :title
      t.timestamps
    end
    create_table :instrument_question_sets do |t|
      t.integer :instrument_id
      t.integer :question_set_id
      t.timestamps
    end
    create_table :instructions do |t|
      t.string :title
      t.text :text
      t.timestamps
    end

    add_column :questions, :question_set_id, :integer
    add_column :questions, :option_set_id, :integer
    add_column :options, :option_set_id, :integer
    add_column :questions, :instruction_id, :integer

    # TODO: Remove foreign_keys from option, question
    # TODO: Remove instructions from question
  end
end
