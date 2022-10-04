class CreateResponseImages < ActiveRecord::Migration[4.2]
  def change
    create_table :response_images do |t|
      t.string :response_uuid
      t.timestamps
    end
  end
end
