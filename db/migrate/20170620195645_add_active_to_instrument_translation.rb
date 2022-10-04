class AddActiveToInstrumentTranslation < ActiveRecord::Migration[4.2]
  def change
    add_column :instrument_translations, :active, :boolean, default: :false
  end
end
