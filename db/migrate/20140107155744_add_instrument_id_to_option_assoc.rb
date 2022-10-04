class AddInstrumentIdToOptionAssoc < ActiveRecord::Migration[4.2]
  def change
    add_column :option_associations, :instrument_id, :integer
  end
end
