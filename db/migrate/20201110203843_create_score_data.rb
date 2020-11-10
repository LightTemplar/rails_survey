# frozen_string_literal: true

class CreateScoreData < ActiveRecord::Migration[5.1]
  def change
    create_table :score_data do |t|
      t.text :content
      t.integer :survey_score_id
      t.float :weight
      t.string :operator
      t.float :score_sum

      t.timestamps
    end
    add_index :score_data, :survey_score_id
    add_index :score_data, %i[survey_score_id operator weight], unique: true
    remove_column :survey_scores, :score_data, :text
    remove_column :survey_scores, :score_sum, :float
    remove_column :centers, :score_data, :text
    remove_column :domain_scores, :survey_score_id
    remove_column :subdomain_scores, :survey_score_id
    add_column :domain_scores, :score_datum_id, :integer
    add_index :domain_scores, :score_datum_id
    add_column :subdomain_scores, :score_datum_id, :integer
    add_index :subdomain_scores, :score_datum_id
  end
end
