class AddColumnUnlessExists < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :follow_up_position, :integer, default: 0 unless column_exists?(:questions, :follow_up_position)
  end
end
