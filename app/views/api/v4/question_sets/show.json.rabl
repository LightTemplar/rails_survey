# frozen_string_literal: true

object @question_set

attributes :id, :title

child :folders do
  extends 'api/v4/folders/show'
end
