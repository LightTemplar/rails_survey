# frozen_string_literal: true

object @option_set

attributes :id, :title, :instruction_id, :special

child :option_in_option_sets do |_os|
  attributes :id, :option_id, :option_set_id, :number_in_question, :special, :instruction_id, :allow_text_entry

  child :option do |_oios|
    extends 'api/templates/v4/option'
  end
end
