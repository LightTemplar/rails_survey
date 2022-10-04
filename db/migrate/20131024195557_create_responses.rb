class CreateResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :responses do |t|
      t.integer :survey_id
      t.string :device_id
      t.integer :question_id
      t.string :text
      t.string :other_response

      t.timestamps
    end
  end
end
