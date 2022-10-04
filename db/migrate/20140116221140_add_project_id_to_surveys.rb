class AddProjectIdToSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :project_id, :integer
  end
end
