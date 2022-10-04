class DropUserRoles < ActiveRecord::Migration[4.2]
  def change
    drop_table :user_roles if table_exists?(:user_roles)
  end
end
