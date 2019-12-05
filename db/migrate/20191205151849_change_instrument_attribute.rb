# frozen_string_literal: true

class ChangeInstrumentAttribute < ActiveRecord::Migration[5.1]
  def change
    rename_column :instruments, :child_update_count, :instrument_questions_count
    rename_column :instruments, :show_sections_page, :require_responses
    remove_column :instruments, :previous_question_count, :integer
    remove_column :instruments, :show_instructions, :boolean
    remove_column :instruments, :special_options, :text
    remove_column :instruments, :navigate_to_review_page, :boolean
    remove_column :instruments, :roster, :boolean
    remove_column :instruments, :roster_type, :string
  end
end
