class CreateExports < ActiveRecord::Migration[4.2]
  def change
    create_table :exports do |t|
      t.string :download_url
      t.boolean :done, default: false
      t.timestamps
    end
  end
end
