class AddProjectIdToUserRoles < ActiveRecord::Migration
  def change
    add_column :user_roles, :project_id, :integer if table_exists?(:user_roles)
  end
end
