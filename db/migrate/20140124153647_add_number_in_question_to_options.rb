class AddNumberInQuestionToOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :options, :number_in_question, :integer
  end
end
