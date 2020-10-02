# frozen_string_literal: true

collection @instrument_questions

attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id,
           :identifier, :table_identifier, :position, :next_question_operator,
           :multiple_skip_operator, :next_question_neutral_ids, :multiple_skip_neutral_ids

child :question do
  attributes :id, :question_identifier, :question_type, :text, :option_set_id,
             :special_option_set_id, :instruction_id, :identifies_survey,
             :validation_id, :pop_up_instruction_id, :after_text_instruction_id,
             :default_response

  child :instruction do
    attributes :id, :title, :text
  end

  child pop_up_instruction: :pop_up_instruction do
    attributes :id, :title, :text
  end

  child after_text_instruction: :after_text_instruction do
    attributes :id, :title, :text
  end

  child :option_set do
    attributes :id, :title, :instruction_id, :special

    child :instruction do
      attributes :id, :title, :text
    end

    child :option_in_option_sets do
      attributes :id, :option_id, :option_set_id, :number_in_question, :special,
                 :instruction_id, :allow_text_entry, :exclusion_ids

      child :instruction do
        attributes :id, :title, :text
      end

      child :option do
        attributes :id, :text, :identifier
      end
    end

    child(other_option: :other_option) { attributes :id, :text, :identifier }
  end

  child special_option_set: :special_option_set do
    attributes :id, :title, :instruction_id, :special

    child :instruction do
      attributes :id, :title, :text
    end

    child :option_in_option_sets do
      attributes :id, :option_id, :option_set_id, :number_in_question, :special,
                 :instruction_id, :allow_text_entry, :exclusion_ids

      child :instruction do
        attributes :id, :title, :text
      end

      child :option do
        attributes :id, :text, :identifier
      end
    end
  end
end

child :next_questions do
  attributes :id, :question_identifier, :option_identifier, :next_question_identifier,
             :value, :complete_survey, :value_operator
end
