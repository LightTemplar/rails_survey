class AddNextQuestionToOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :options, :next_question, :string
  end
end
