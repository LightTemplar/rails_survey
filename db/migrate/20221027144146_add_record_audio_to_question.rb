class AddRecordAudioToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :record_audio, :boolean, default: :false
    add_column :instrument_questions, :show_number, :boolean, default: :true
  end
end
