# frozen_string_literal: true

object @question_set

attributes :id, :title

child :folders do
  extends 'api/templates/v4/folder'
end
