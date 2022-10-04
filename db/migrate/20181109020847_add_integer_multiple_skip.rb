class AddIntegerMultipleSkip < ActiveRecord::Migration[4.2]
  def change
    add_column :multiple_skips, :value, :string
  end
end
