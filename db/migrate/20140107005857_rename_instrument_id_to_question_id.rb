class RenameInstrumentIdToQuestionId < ActiveRecord::Migration[4.2]
  def change
    rename_column :option_associations, :instrument_id, :question_id
    rename_column :option_associations, :instrument_version, :question_version
  end
end
