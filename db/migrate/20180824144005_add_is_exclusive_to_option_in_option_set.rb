class AddIsExclusiveToOptionInOptionSet < ActiveRecord::Migration[4.2]
  def change
    add_column :option_in_option_sets, :is_exclusive, :boolean, default: false
  end
end
