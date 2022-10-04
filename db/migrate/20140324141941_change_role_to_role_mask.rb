class ChangeRoleToRoleMask < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :role, :roles_mask
  end
end
