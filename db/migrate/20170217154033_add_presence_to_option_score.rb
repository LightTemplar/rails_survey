class AddPresenceToOptionScore < ActiveRecord::Migration
  def change
    add_column :option_scores, :exists, :boolean
  end
end
