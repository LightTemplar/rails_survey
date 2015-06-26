class AddAttributesToScores < ActiveRecord::Migration
  def change
    add_column :scores, :survey_uuid, :string
    add_column :scores, :device_label, :string
    add_column :scores, :device_user, :string
    add_column :scores, :survey_start_time, :string
    add_column :scores, :survey_end_time, :string
    add_column :scores, :center_id, :string
    rename_table :scores, :survey_scores
  end
end
