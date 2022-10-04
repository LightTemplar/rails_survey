class AddUuidToResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :uuid, :string
  end
end
