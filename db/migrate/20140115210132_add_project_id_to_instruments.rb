class AddProjectIdToInstruments < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :project_id, :integer
  end
end
