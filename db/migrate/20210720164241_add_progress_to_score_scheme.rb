class AddProgressToScoreScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :score_schemes, :progress, :integer, default: 0
  end
end
