class RemoveProjectIdFromSurveys < ActiveRecord::Migration[4.2]
  def change
    remove_column :surveys, :project_id
  end
end
