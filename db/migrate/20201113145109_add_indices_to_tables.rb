class AddIndicesToTables < ActiveRecord::Migration
  def change
    add_index :instrument_questions, :instrument_id unless index_exists?(:instrument_questions, :instrument_id)
    add_index :instrument_questions, :display_id unless index_exists?(:instrument_questions, :display_id)
    add_index :instrument_questions, :number_in_instrument unless index_exists?(:instrument_questions, :number_in_instrument)

    add_index :responses, :question_id unless index_exists?(:responses, :question_id)
    add_index :responses, :question_identifier unless index_exists?(:responses, :question_identifier)

    add_index :questions, :option_set_id unless index_exists?(:questions, :option_set_id)
    add_index :questions, :special_option_set_id unless index_exists?(:questions, :special_option_set_id)
    add_index :questions, :question_set_id unless index_exists?(:questions, :question_set_id)
    add_index :questions, :instruction_id unless index_exists?(:questions, :instruction_id)

    add_index :option_in_option_sets, :option_id unless index_exists?(:option_in_option_sets, :option_id)
    add_index :option_in_option_sets, :option_set_id unless index_exists?(:option_in_option_sets, :option_set_id)
    add_index :option_in_option_sets, :number_in_question unless index_exists?(:option_in_option_sets, :number_in_question)

    add_index :surveys, :instrument_id unless index_exists?(:surveys, :instrument_id)

    add_index :displays, :section_id unless index_exists?(:displays, :section_id)
    add_index :displays, :instrument_id unless index_exists?(:displays, :instrument_id)
    add_index :displays, :position unless index_exists?(:displays, :position)

    add_index :folders, :question_set_id unless index_exists?(:folders, :question_set_id)

    add_index :option_sets, :instruction_id unless index_exists?(:option_sets, :instruction_id)

    add_index :user_projects, :user_id unless index_exists?(:user_projects, :user_id)
    add_index :user_projects, :project_id unless index_exists?(:user_projects, :project_id)

    add_index :sections, :instrument_id unless index_exists?(:sections, :instrument_id)

    add_index :section_translations, :section_id unless index_exists?(:section_translations, :section_id)
    add_index :section_translations, :language unless index_exists?(:section_translations, :language)

    add_index :loop_questions, :instrument_question_id unless index_exists?(:loop_questions, :instrument_question_id)

    add_index :multiple_skips, :instrument_question_id unless index_exists?(:multiple_skips, :instrument_question_id)
    add_index :multiple_skips, :option_identifier unless index_exists?(:multiple_skips, :option_identifier)

    add_index :next_questions, :instrument_question_id unless index_exists?(:next_questions, :instrument_question_id)
    add_index :next_questions, :option_identifier unless index_exists?(:next_questions, :option_identifier)

    add_index :critical_responses, :question_identifier unless index_exists?(:critical_responses, :question_identifier)
    add_index :critical_responses, :option_identifier unless index_exists?(:critical_responses, :option_identifier)
    add_index :critical_responses, :instruction_id unless index_exists?(:critical_responses, :instruction_id)

    add_index :option_translations, :option_id unless index_exists?(:option_translations, :option_id)
    add_index :option_translations, :language unless index_exists?(:option_translations, :language)

    add_index :option_set_translations, :option_set_id unless index_exists?(:option_set_translations, :option_set_id)
    add_index :option_set_translations, :option_translation_id unless index_exists?(:option_set_translations, :option_translation_id)

    add_index :instruction_translations, :instruction_id unless index_exists?(:instruction_translations, :instruction_id)
    add_index :instruction_translations, :language unless index_exists?(:instruction_translations, :language)

    add_index :question_translations, :question_id unless index_exists?(:question_translations, :question_id)
    add_index :question_translations, :language unless index_exists?(:question_translations, :language)
  end
end
