class AddPrecisionToRate < ActiveRecord::Migration[4.2]
  def change
    change_column :surveys, :completion_rate, :decimal, precision: 3, scale: 2
  end
end
