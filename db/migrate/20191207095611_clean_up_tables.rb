# frozen_string_literal: true

class CleanUpTables < ActiveRecord::Migration[5.1]
  def change
    remove_column :surveys, :roster_uuid, :string
    add_column :questions, :pdf_response_height, :integer
    add_column :questions, :pdf_print_options, :boolean, default: true
    add_column :questions, :pop_up_instruction, :boolean, default: false
    add_column :option_in_option_sets, :instruction_id, :integer
    add_column :option_in_option_sets, :allow_text_entry, :boolean, default: false
  end
end
