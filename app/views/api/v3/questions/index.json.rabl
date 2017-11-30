collection @questions
cache ['v3-questions', @questions]

attributes :id, :instrument_id, :display_id, :number_in_instrument
# ,:following_up_question_identifier,
# :follow_up_position, :section_id

# node :id do |iq|
#   iq.question.id
# end

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

node :instrument_version do |iq|
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

node :option_set_id do |iq|
  iq.question.option_set_id
end

node :deleted_at do |iq|
  iq.question.deleted_at
end

node :identifies_survey do |iq|
  iq.question.identifies_survey
end

node :reg_ex_validation do |iq|
  iq.question.reg_ex_validation
end

node :reg_ex_validation_message do |iq|
  iq.question.reg_ex_validation_message
end

node :following_up_question_identifier do |iq|
  iq.question.following_up_question_identifier
end

node :follow_up_position do |iq|
  iq.question.follow_up_position
end

child :translations do |t|
  attributes :id, :question_id, :text, :language, :instructions
end

# ??? needs to be explored
# :grid_id, :number_in_grid,
