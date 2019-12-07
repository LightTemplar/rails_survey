# frozen_string_literal: true

class Api::V3::SurveysController < Api::V3::ApiController
  respond_to :json

  def create
    @survey = Survey.where(uuid: params[:survey][:uuid])&.first
    if @survey
      record_device_attributes
      if @survey.update_attributes(survey_params)
        render json: @survey, status: :accepted
      else
        render json: { errors: @survey.errors.full_messages }, status: :unprocessable_entity
      end
    else
      @survey = Survey.new(survey_params)
      record_device_attributes
      if @survey.save
        render json: @survey, status: :created
      else
        head :unprocessable_entity
      end
    end
  end

  private

  def record_device_attributes
    device = Device.find_or_create_by(identifier: params[:survey][:device_uuid])
    @survey.device_id = device.id
    project = Project.find_by_id(params[:project_id])
    device.projects << project unless device.projects.include?(project)
    device.identifier = params[:survey][:device_uuid]
    device.label = params[:survey][:device_label]
    device.save
  end

  def survey_params
    params.require(:survey).permit(:instrument_id, :instrument_version_number,
                                   :uuid, :device_id, :instrument_title,
                                   :device_uuid, :latitude, :longitude, :metadata,
                                   :completion_rate, :device_label, :language,
                                   :skipped_questions, :completed_responses_count)
  end
end
