class AddSpecialResponseToResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :special_response, :string
  end
end
