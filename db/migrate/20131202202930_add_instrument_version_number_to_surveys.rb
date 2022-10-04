class AddInstrumentVersionNumberToSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :instrument_version_number, :integer
  end
end
