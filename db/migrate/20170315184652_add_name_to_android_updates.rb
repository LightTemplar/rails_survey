class AddNameToAndroidUpdates < ActiveRecord::Migration[4.2]
  def change
    add_column :android_updates, :name, :string
  end
end
