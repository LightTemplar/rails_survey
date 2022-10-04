class AddLanguageAndAlignmentToInstruments < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :language, :string
    add_column :instruments, :alignment, :string
  end
end
