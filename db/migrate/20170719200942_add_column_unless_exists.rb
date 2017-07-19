class AddColumnUnlessExists < ActiveRecord::Migration
  def change
    unless column_exists?(:questions, :follow_up_position)
      add_column :questions, :follow_up_position, :integer, default: 0
    end
  end
end
