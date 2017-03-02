object @option

attributes :id, :text, :question_id, :created_at, :updated_at, :next_question, :deleted_at, :number_in_question, :instrument_version_number, :critical, :special, :instrument_version

child :translations do
  attributes :id, :option_id, :text, :created_at, :updated_at, :language, :option_changed
end
