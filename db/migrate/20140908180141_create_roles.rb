class CreateRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :roles do |t|
      t.string :name
      t.timestamps
    end
    default_roles = %w[admin manager translator analyst user]
    default_roles.each do |role|
      Role.create(name: role)
    end
    remove_column :users, :roles_mask
  end
end
