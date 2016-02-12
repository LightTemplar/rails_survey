class AddCriticalToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :critical, :boolean
    add_column :options, :critical, :boolean
    add_column :instruments, :critical_message, :text
    add_column :instrument_translations, :critical_message, :text
    add_column :surveys, :has_critical_responses, :boolean
  end
end