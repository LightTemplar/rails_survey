class AddNumberInInstrumentToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :number_in_instrument, :integer
  end
end
