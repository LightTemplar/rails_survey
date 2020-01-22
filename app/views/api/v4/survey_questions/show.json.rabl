# frozen_string_literal: true

object @question

attributes :id, :question_identifier, :question_type, :text, :option_set_id,
           :special_option_set_id, :instruction_id, :pop_up_instruction_id, :position

child :translations do
  extends 'api/v4/question_translations/show'
end

child :options do
  extends 'api/templates/v4/option'

  child :translations do
    extends 'api/v4/option_translations/show'
  end
end
