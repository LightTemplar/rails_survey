class AddColumnRosterToInstruments < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :roster, :boolean, default: false
    add_column :instruments, :roster_type, :string
  end
end
