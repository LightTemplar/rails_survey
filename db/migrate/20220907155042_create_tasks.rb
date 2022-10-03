class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
    create_table :task_option_sets do |t|
      t.integer :task_id
      t.integer :option_set_id
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
    create_table :diagrams do |t|
      t.integer :option_id
      t.integer :question_id
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
    add_column :questions, :task_id, :integer
    remove_column :options, :instrument_version_number, :integer
    add_column :options, :text_one, :string
    add_column :options, :text_two, :string
    add_column :option_translations, :text_one, :string
    add_column :option_translations, :text_two, :string
  end
end
