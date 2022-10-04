class AddIndexToResponseImages < ActiveRecord::Migration[4.2]
  def change
    add_index :responses, :uuid
  end
end
