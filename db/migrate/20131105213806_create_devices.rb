class CreateDevices < ActiveRecord::Migration[4.2]
  def change
    create_table :devices do |t|
      t.string :identifier

      t.timestamps
    end
  end
end
