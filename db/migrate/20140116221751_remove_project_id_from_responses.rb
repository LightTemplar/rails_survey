class RemoveProjectIdFromResponses < ActiveRecord::Migration[4.2]
  def change
    remove_column :responses, :project_id
  end
end
