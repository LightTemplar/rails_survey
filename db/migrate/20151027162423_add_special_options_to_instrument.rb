class AddSpecialOptionsToInstrument < ActiveRecord::Migration
  def change
    add_column :instruments, :special_options, :text
    add_column :options, :special, :boolean, default: false
  end
end