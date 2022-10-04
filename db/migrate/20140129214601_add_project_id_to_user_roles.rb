class AddProjectIdToUserRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :user_roles, :project_id, :integer if table_exists?(:user_roles)
  end
end
