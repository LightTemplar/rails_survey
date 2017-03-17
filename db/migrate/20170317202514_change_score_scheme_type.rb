class ChangeScoreSchemeType < ActiveRecord::Migration
  def change
    change_column :score_schemes, :instrument_id, 'integer USING CAST(instrument_id AS integer)'
  end
end
