class ChangePositionToInteger < ActiveRecord::Migration
  def change
    change_column :displays, :position, 'integer USING CAST(position AS integer)'
  end
end
