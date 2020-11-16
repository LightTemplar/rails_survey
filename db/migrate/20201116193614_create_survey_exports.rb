class CreateSurveyExports < ActiveRecord::Migration
  def change
    create_table :survey_exports do |t|
      t.integer :survey_id
      t.text :long
      t.text :short
      t.text :wide
      t.datetime :last_response_at

      t.timestamps null: false
    end
    add_index :survey_exports, :survey_id
    remove_column :response_exports, :project_id, :integer
    remove_column :response_exports, :long_done, :boolean
    remove_column :response_exports, :wide_done, :boolean
    remove_column :response_exports, :short_done, :boolean
  end
end
