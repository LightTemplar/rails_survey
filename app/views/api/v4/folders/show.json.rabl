# frozen_string_literal: true

object @folder

attributes :id, :title

child :questions do
  attributes :id, :question_identifier, :text, :question_set_id, :folder_id, :question_type
end
