class AddIdentifierToInstrumentQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :instrument_questions, :identifier, :string
  end
end
