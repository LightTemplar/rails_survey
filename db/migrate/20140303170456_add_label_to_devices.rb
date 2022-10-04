class AddLabelToDevices < ActiveRecord::Migration[4.2]
  def change
    add_column :devices, :label, :string
  end
end
