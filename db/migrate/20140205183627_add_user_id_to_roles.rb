class AddUserIdToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :user_id, :integer if table_exists?(:roles)
  end
end
