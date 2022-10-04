class AddInstrumentIdToSections < ActiveRecord::Migration[4.2]
  def change
    add_column :sections, :instrument_id, :integer
  end
end
