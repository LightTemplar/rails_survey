class AddUuidToScores < ActiveRecord::Migration
  def change
    add_column :scores, :uuid, :string
    add_column :scores, :survey_uuid, :string
    add_column :scores, :device_uuid, :string
    add_column :scores, :device_label, :string
    add_column :raw_scores, :uuid, :string
    add_column :raw_scores, :score_uuid, :string
  end
end
