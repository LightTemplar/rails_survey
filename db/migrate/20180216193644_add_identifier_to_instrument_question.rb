class AddIdentifierToInstrumentQuestion < ActiveRecord::Migration
  def change
    add_column :instrument_questions, :identifier, :string
  end
end
