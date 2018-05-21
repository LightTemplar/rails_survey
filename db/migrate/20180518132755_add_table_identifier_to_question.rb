class AddTableIdentifierToQuestion < ActiveRecord::Migration
  def change
    add_column :instrument_questions, :table_identifier, :string
  end
end
