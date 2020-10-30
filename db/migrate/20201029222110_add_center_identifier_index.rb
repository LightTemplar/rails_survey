# frozen_string_literal: true

class AddCenterIdentifierIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :centers, :identifier
    add_index :responses, :question_identifier
    add_index :option_scores, :option_identifier
    add_index :option_scores, :score_unit_question_id
    add_index :survey_scores, %i[survey_id score_scheme_id]
    add_index :score_units, :subdomain_id
    add_index :score_units, :title
    add_index :domains, :score_scheme_id
    add_index :subdomains, :domain_id
    add_index :instrument_questions, :identifier
    add_index :score_unit_questions, :score_unit_id
    add_index :score_unit_questions, :instrument_question_id
    add_index :raw_scores, :score_unit_id
    add_index :raw_scores, :survey_score_id
    add_index :raw_scores, :response_id
    add_index :raw_scores, %i[score_unit_id survey_score_id]
    add_index :questions, :option_set_id
    add_index :questions, :special_option_set_id
    add_index :option_in_option_sets, :option_id
    add_index :option_in_option_sets, :option_set_id
    add_index :option_in_option_sets, :instruction_id
    add_index :option_in_option_sets, :number_in_question
    add_index :surveys, :instrument_id
    add_index :score_scheme_centers, :center_id
    add_index :score_scheme_centers, :score_scheme_id
  end
end
