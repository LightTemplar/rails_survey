class AddPresenceToOptionScore < ActiveRecord::Migration[4.2]
  def change
    add_column :option_scores, :exists, :boolean
  end
end
