# frozen_string_literal: true

class Api::V3::ResponsesController < Api::V3::ApiController
  respond_to :json

  def create
    @response = Response.where(uuid: params[:response][:uuid])&.first
    if @response
      modify_timestamps
      if @response.update_attributes(response_params)
        record_device_attributes
        render json: @response, status: :accepted
      else
        render json: { errors: @response.errors.full_messages }, status: :unprocessable_entity
      end
    else
      @response = Response.new(response_params)
      modify_timestamps
      if @response.save
        record_device_attributes
        render json: @response, status: :created
      else
        render json: { errors: @response.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def modify_timestamps
    @response.time_started = Time.at(params[:response][:time_started] / 1000).to_datetime if params[:response][:time_started]
    @response.time_ended = Time.at(params[:response][:time_ended] / 1000).to_datetime if params[:response][:time_ended]
  end

  def record_device_attributes
    project = Project.find(params[:project_id])
    device_user = DeviceUser.find_by_id(params[:response][:device_user_id]) if params[:response][:device_user_id]
    project.device_users << device_user if device_user && !project.device_users.include?(device_user)
    device = @response.survey.device if @response.survey
    device_user.devices << device if device_user && device && !device_user.devices.include?(device)
  end

  def response_params
    params.require(:response).permit(:question_id, :text, :other_response,
                                     :special_response, :survey_uuid, :time_started, :time_ended,
                                     :question_identifier, :uuid, :device_user_id, :question_version,
                                     :randomized_data, :rank_order, :other_text)
  end
end
