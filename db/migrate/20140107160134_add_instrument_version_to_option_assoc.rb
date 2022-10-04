class AddInstrumentVersionToOptionAssoc < ActiveRecord::Migration[4.2]
  def change
    add_column :option_associations, :instrument_version, :integer
  end
end
