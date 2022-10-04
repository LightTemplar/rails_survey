class ChangePositionToInteger < ActiveRecord::Migration[4.2]
  def change
    change_column :displays, :position, 'integer USING CAST(position AS integer)'
  end
end
