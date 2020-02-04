# frozen_string_literal: true

class Api::V3::SurveyNotesController < Api::V3::ApiController
  respond_to :json

  def create
    @survey_note = SurveyNote.where(uuid: params[:survey_note][:uuid])&.first
    if @survey_note
      if @survey_note.update_attributes(survey_note_params)
        render json: @survey_note, status: :accepted
      else
        render json: { errors: @survey_note.errors.full_messages }, status: :unprocessable_entity
      end
    else
      @survey_note = SurveyNote.new(survey_note_params)
      if @survey_note.save
        render json: @survey_note, status: :created
      else
        render json: { errors: @survey_note.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def survey_note_params
    params.require(:survey_note).permit(:uuid, :survey_uuid, :device_user_id, :reference, :text)
  end
end
