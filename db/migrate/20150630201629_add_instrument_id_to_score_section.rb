class AddInstrumentIdToScoreSection < ActiveRecord::Migration
  def change
    add_column :score_sections, :instrument_id, :integer
  end
end
