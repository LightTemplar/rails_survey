# frozen_string_literal: true

class GenerateScoringModels < ActiveRecord::Migration[4.2]
  def change
    add_column :score_schemes, :active, :boolean

    add_column :score_units, :subdomain_id, :integer
    remove_column :score_units, :min, :float
    remove_column :score_units, :max, :float
    remove_column :score_units, :question_type, :integer
    remove_column :score_units, :score_scheme_id, :integer
    change_column :score_units, :score_type, :string

    add_column :option_scores, :option_identifier, :string
    add_column :option_scores, :follow_up_qid, :string
    add_column :option_scores, :position, :string
    remove_column :option_scores, :option_id, :integer
    remove_column :option_scores, :next_question, :boolean
    remove_column :option_scores, :exists, :boolean
    remove_column :option_scores, :label, :string

    rename_column :score_unit_questions, :question_id, :instrument_question_id

    rename_table :scores, :survey_scores
    add_column :survey_scores, :deleted_at, :datetime

    rename_column :raw_scores, :score_id, :survey_score_id
    rename_column :raw_scores, :score_uuid, :survey_score_uuid
    add_column :raw_scores, :deleted_at, :datetime

    create_table :domains do |t|
      t.string :title
      t.integer :score_scheme_id
      t.datetime :deleted_at
      t.timestamps null: false
    end
    add_index :domains, :deleted_at

    create_table :subdomains do |t|
      t.string :title
      t.integer :domain_id
      t.datetime :deleted_at
      t.timestamps null: false
    end
    add_index :subdomains, :deleted_at
  end
end
