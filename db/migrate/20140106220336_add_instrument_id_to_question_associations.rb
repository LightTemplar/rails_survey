class AddInstrumentIdToQuestionAssociations < ActiveRecord::Migration[4.2]
  def change
    add_column :question_associations, :instrument_id, :integer
  end
end
