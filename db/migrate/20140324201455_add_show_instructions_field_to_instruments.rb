class AddShowInstructionsFieldToInstruments < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :show_instructions, :boolean, default: false
  end
end
