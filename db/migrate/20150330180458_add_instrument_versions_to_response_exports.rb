class AddInstrumentVersionsToResponseExports < ActiveRecord::Migration[4.2]
  def change
    add_column :response_exports, :instrument_versions, :text
  end
end
