class CreateAndroidUpdates < ActiveRecord::Migration[4.2]
  def change
    create_table :android_updates do |t|
      t.integer :version

      t.timestamps
    end
  end
end
