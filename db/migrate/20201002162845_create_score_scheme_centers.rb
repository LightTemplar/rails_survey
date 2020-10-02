# frozen_string_literal: true

class CreateScoreSchemeCenters < ActiveRecord::Migration[5.1]
  def change
    create_table :score_scheme_centers do |t|
      t.integer :center_id
      t.integer :score_scheme_id
      t.timestamps
    end
    remove_column :centers, :score_scheme_id
  end
end
