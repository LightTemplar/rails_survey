class AddUserIdToRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :user_id, :integer if table_exists?(:roles)
  end
end
