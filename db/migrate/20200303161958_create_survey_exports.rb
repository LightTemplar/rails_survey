# frozen_string_literal: true

class CreateSurveyExports < ActiveRecord::Migration[5.1]
  def change
    create_table :survey_exports do |t|
      t.integer :survey_id
      t.text :long
      t.text :short
      t.text :wide
      t.datetime :last_response_at

      t.timestamps
    end
    remove_column :response_exports, :project_id, :integer
    remove_column :response_exports, :long_done, :boolean
    remove_column :response_exports, :wide_done, :boolean
    remove_column :response_exports, :short_done, :boolean
  end
end
