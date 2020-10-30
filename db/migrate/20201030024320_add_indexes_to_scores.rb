# frozen_string_literal: true

class AddIndexesToScores < ActiveRecord::Migration[5.1]
  def change
    add_index :subdomain_scores, :subdomain_id
    add_index :subdomain_scores, :survey_score_id
    add_index :domain_scores, :domain_id
    add_index :domain_scores, :survey_score_id
  end
end
