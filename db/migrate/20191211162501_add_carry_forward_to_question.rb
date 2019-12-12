# frozen_string_literal: true

class AddCarryForwardToQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :instrument_questions, :carry_forward_identifier, :string
    add_column :questions, :default_response, :text

    create_table :survey_notes do |t|
      t.string :uuid
      t.string :survey_uuid
      t.integer :device_user_id
      t.string :reference
      t.text :text

      t.timestamps null: false
    end
    add_index(:survey_notes, :uuid)
    add_index(:survey_notes, :survey_uuid)
  end
end
