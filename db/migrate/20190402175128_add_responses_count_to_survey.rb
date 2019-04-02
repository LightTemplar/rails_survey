# frozen_string_literal: true

class AddResponsesCountToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :completed_responses_count, :integer
  end
end
