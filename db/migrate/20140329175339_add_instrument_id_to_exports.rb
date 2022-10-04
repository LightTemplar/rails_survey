class AddInstrumentIdToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :instrument_id, :integer
  end
end
