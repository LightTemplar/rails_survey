class AddSpecialToOptionSet < ActiveRecord::Migration[4.2]
  def change
    add_column :option_sets, :special, :boolean, default: false
    add_column :questions, :special_option_set_id, :integer
  end
end
