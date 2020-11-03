# frozen_string_literal: true

class AddIndexToDisplays < ActiveRecord::Migration[5.1]
  def change
    add_index :displays, :section_id
    add_index :displays, :instrument_id
    add_index :displays, :position
    add_index :instrument_questions, :position
    add_index :folders, :question_set_id
    add_index :folders, :position
    add_index :questions, :question_set_id
    add_index :questions, :position
    add_index :questions, :instruction_id
    add_index :questions, :pop_up_instruction_id
    add_index :questions, :after_text_instruction_id
    add_index :option_sets, :instruction_id
    add_index :user_projects, :user_id
    add_index :user_projects, :project_id
    add_index :sections, :instrument_id
    add_index :sections, :position
    add_index :section_translations, :section_id
    add_index :section_translations, :language
    add_index :instrument_questions, :number_in_instrument
    add_index :loop_questions, :instrument_question_id
    add_index :multiple_skips, :instrument_question_id
    add_index :multiple_skips, :option_identifier
    add_index :next_questions, :instrument_question_id
    add_index :next_questions, :option_identifier
    add_index :critical_responses, :question_identifier
    add_index :critical_responses, :option_identifier
    add_index :critical_responses, :instruction_id
  end
end
