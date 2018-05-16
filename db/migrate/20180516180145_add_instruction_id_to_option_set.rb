class AddInstructionIdToOptionSet < ActiveRecord::Migration
  def change
    add_column :option_sets, :instruction_id, :integer
  end
end
