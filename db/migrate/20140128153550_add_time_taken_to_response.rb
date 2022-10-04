class AddTimeTakenToResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :time_started, :datetime
    add_column :responses, :time_ended, :datetime
  end
end
