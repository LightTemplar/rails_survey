collection @questions
cache ['v3-questions', @questions]

attributes :id, :instrument_id, :display_id, :number_in_instrument, :deleted_at

# node :id do |iq|
#   iq.question.id
# end

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

# node :deleted_at do |iq|
#   iq.question.deleted_at if iq.question
# end

node :identifies_survey do |iq|
  iq.question.identifies_survey if iq.question
end

node :reg_ex_validation do |iq|
  iq.question.reg_ex_validation if iq.question
end

node :reg_ex_validation_message do |iq|
  iq.question.reg_ex_validation_message if iq.question
end

child :translations do |t|
  attributes :id, :question_id, :text, :language, :instructions
end

# ??? needs to be explored
# :grid_id, :number_in_grid,
