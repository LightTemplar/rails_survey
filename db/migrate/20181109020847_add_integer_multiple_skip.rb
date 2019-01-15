class AddIntegerMultipleSkip < ActiveRecord::Migration
  def change
    add_column :multiple_skips, :value, :string
  end
end
