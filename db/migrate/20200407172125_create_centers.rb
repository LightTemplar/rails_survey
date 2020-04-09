# frozen_string_literal: true

class CreateCenters < ActiveRecord::Migration[5.1]
  def change
    create_table :centers do |t|
      t.integer :score_scheme_id
      t.string :identifier
      t.string :name
      t.string :center_type
      t.string :administration
      t.string :region
      t.string :department
      t.string :municipality
      t.text :score_data

      t.timestamps
    end
    add_column :survey_scores, :identifier, :string
    add_index :survey_scores, :identifier
    add_index :centers, %i[score_scheme_id identifier], unique: true
  end
end
