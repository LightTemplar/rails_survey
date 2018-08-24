class AddIsExclusiveToOptionInOptionSet < ActiveRecord::Migration
  def change
    add_column :option_in_option_sets, :is_exclusive, :boolean, default: false
  end
end
