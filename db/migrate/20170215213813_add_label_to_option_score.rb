class AddLabelToOptionScore < ActiveRecord::Migration
  def change
    add_column :option_scores, :label, :string
    remove_column :score_units, :score_per_selection
  end
end
