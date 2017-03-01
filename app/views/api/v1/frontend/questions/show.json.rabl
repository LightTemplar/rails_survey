object @question
cache @question
attributes :id, :text, :question_type, :question_identifier, :instrument_id, :created_at, :updated_at, :following_up_question_identifier, :deleted_at, :reg_ex_validation, :number_in_instrument, :reg_ex_validation_message, :follow_up_position, :identifies_survey, :instructions, :child_update_count, :grid_id, :first_in_grid, :instrument_version_number, :section_id, :critical, :option_count, :image_count, :instrument_version, :question_version, :project_id

child :options do
  attributes :id, :question_id, :text, :created_at, :updated_at, :next_question, :number_in_question, :deleted_at, :instrument_version_number, :special, :critical, :instrument_version
end

child :option_skips do
  attributes :id, :option_id, :question_identifier, :created_at, :updated_at, :deleted_at
end

child :images do
  attributes :id, :photo_file_name, :photo_file_size, :photo_content_type, :photo_updated_at, :question_id, :description, :number, :created_at, :updated_at, :photo_url
end
