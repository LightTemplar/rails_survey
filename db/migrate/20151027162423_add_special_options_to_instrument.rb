class AddSpecialOptionsToInstrument < ActiveRecord::Migration
  def change
    add_column :instruments, :special_options, :text
  end
end