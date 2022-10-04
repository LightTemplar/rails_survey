class AddProjectIdToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :project_id, :integer
  end
end
