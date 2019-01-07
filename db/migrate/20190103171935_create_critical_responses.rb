class CreateCriticalResponses < ActiveRecord::Migration
  def change
    create_table :critical_responses do |t|
      t.string :question_identifier
      t.string :option_identifier
      t.integer :instruction_id
      t.datetime :deleted_at
      t.timestamps null: false
    end
    remove_column :options, :critical, :boolean
    remove_column :questions, :critical, :boolean
    remove_column :instruments, :critical_message, :text
    remove_column :instrument_translations, :critical_message, :text
    remove_column :surveys, :has_critical_responses, :boolean
  end
end
