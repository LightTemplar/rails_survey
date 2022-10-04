class AddValueToNextQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :next_questions, :value, :string
  end
end
