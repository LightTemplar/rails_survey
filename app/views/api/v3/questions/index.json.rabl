collection @questions
cache @questions

attributes :id, :instrument_id, :display_id, :number_in_instrument, :option_set_id

# attributes :following_up_question_identifier, :deleted_at, :reg_ex_validation,
# :reg_ex_validation_message, :follow_up_position, :identifies_survey, :section_id

node :text do |iq|
  iq.question.text
end

node :question_type do |iq|
  iq.question.question_type
end

node :question_identifier do |iq|
  iq.question.question_identifier
end

node :instructions do |iq|
  iq.question.try(:instruction).try(:text)
end

node :instrument_version_number do |iq|
  iq.instrument.current_version_number
end

node :question_version do |iq|
 iq.question.question_version
end

node :option_count do |iq|
 iq.question.try(:option_set).try(:options).try(:size)
end

node :critical do |iq|
  iq.question.critical
end

node :image_count do |iq|
 iq.question.images.size
end

# ??? needs to be explored
# :grid_id, :number_in_grid,
