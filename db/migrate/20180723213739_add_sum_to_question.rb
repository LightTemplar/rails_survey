class AddSumToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :sum_of_parts, :decimal, precision: 15, scale: 5
    add_column :instrument_questions, :sum_of_parts_identifier, :string
  end
end
