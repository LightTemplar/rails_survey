class AddSpecialOptionsToInstrument < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :special_options, :text
    add_column :options, :special, :boolean, default: false
  end
end
