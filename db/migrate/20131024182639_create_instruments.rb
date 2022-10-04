class CreateInstruments < ActiveRecord::Migration[4.2]
  def change
    create_table :instruments do |t|
      t.string :title

      t.timestamps
    end
  end
end
