# frozen_string_literal: true

object @instrument

attributes :id, :title, :language, :alignment, :project_id, :published

child :instrument_questions do
  attributes :id, :instrument_id, :question_id, :number_in_instrument,
             :display_id, :identifier, :table_identifier, :position
end
