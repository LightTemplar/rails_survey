class AddValueToNextQuestion < ActiveRecord::Migration
  def change
    add_column :next_questions, :value, :string
  end
end
