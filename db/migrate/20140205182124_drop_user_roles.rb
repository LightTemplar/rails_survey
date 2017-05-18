class DropUserRoles < ActiveRecord::Migration
  def change
    drop_table :user_roles if table_exists?(:user_roles)
  end
end
