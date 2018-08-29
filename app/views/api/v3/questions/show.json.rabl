object @question
cache @question

attributes :id, :instrument_id, :display_id, :number_in_instrument, :deleted_at, :table_identifier

node :text do |iq|
  iq.question.text if iq.question
end

node :question_type do |iq|
  iq.question.question_type if iq.question
end

node :question_identifier do |iq|
  # iq.question.question_identifier if iq.question
  iq.identifier
end

node :instructions do |iq|
  iq.question.try(:instruction).try(:text) if iq.question
end

node :instrument_version do |iq|
  iq.instrument.current_version_number if iq.instrument
end

node :question_version do |iq|
 iq.question.question_version if iq.question
end

node :option_count do |iq|
 iq.question.try(:option_set).try(:options).try(:size) if iq.question
end

node :critical do |iq|
  iq.question.critical if iq.question
end

node :image_count do |iq|
 iq.question.images.size if iq.question
end

node :option_set_id do |iq|
  iq.question.option_set_id if iq.question
end

node :special_option_set_id do |iq|
  iq.question.special_option_set_id if iq.question
end

node :identifies_survey do |iq|
  iq.question.identifies_survey if iq.question
end

node :validation_id do |iq|
  iq.question.validation_id if iq.question
end

node :rank_responses do |iq|
  iq.question.rank_responses if iq.question
end

child :translations do |t|
  attributes :id, :question_id, :text, :language, :instructions
end
