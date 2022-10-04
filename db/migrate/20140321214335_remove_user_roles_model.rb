class RemoveUserRolesModel < ActiveRecord::Migration[4.2]
  def change
    drop_table :roles if table_exists?(:roles)
    add_column :users, :role, :integer
  end
end
