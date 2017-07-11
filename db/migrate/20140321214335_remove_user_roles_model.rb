class RemoveUserRolesModel < ActiveRecord::Migration
  def change
    drop_table :roles if table_exists?(:roles)
    add_column :users, :role, :integer
  end
end
