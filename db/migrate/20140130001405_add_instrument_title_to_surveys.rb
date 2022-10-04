class AddInstrumentTitleToSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :instrument_title, :string
  end
end
