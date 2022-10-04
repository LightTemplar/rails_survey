# frozen_string_literal: true

class AddResponsesCountToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :completed_responses_count, :integer
  end
end
