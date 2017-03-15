class AddNameToAndroidUpdates < ActiveRecord::Migration
  def change
    add_column :android_updates, :name, :string
  end
end
