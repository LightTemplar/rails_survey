class AddPublishedToInstruments < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :published, :boolean
  end
end
