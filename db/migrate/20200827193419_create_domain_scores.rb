# frozen_string_literal: true

class CreateDomainScores < ActiveRecord::Migration[5.1]
  def change
    create_table :domain_scores do |t|
      t.integer :domain_id
      t.integer :survey_score_id
      t.float :score_sum
      t.timestamps
    end
    create_table :subdomain_scores do |t|
      t.integer :subdomain_id
      t.integer :survey_score_id
      t.float :score_sum
      t.timestamps
    end
  end
end
