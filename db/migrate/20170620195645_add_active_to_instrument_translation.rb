class AddActiveToInstrumentTranslation < ActiveRecord::Migration
  def change
    add_column :instrument_translations, :active, :boolean, default: :false
  end
end
