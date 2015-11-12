class ChangeAdminUsersTable < ActiveRecord::Migration
  def change
    remove_index :admin_users, name: :index_admin_users_on_email
    remove_index :admin_users, name: :index_admin_users_on_reset_password_token
    drop_table :admin_users
  end
end