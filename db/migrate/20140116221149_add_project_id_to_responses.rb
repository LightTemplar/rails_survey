class AddProjectIdToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :project_id, :integer
  end
end
