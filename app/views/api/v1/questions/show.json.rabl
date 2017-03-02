object @question
cache ['v1', @question]
attributes :id, :text, :question_type, :question_identifier, :instrument_id, :created_at, :updated_at, :following_up_question_identifier, :deleted_at, :reg_ex_validation, :number_in_instrument, :reg_ex_validation_message, :follow_up_position, :identifies_survey, :instructions, :child_update_count, :grid_id, :first_in_grid, :instrument_version_number, :section_id, :critical, :option_count, :image_count, :instrument_version, :question_version

child :translations do
  extends 'api/translations/question'
end
