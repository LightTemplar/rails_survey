class AddLabelToOptionScore < ActiveRecord::Migration[4.2]
  def change
    add_column :option_scores, :label, :string
    remove_column :score_units, :score_per_selection
  end
end
