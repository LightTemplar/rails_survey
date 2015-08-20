module Api
  module V1
    class ResponsesController < ApiApplicationController
      protect_from_forgery with: :null_session
      respond_to :json

      def create
        @response = Response.new(params[:response])
        record_device_attributes
        if @response.save
          render json: @response, status: :created
        else
          render nothing: true, status: :unprocessable_entity
        end
      end

      private
      def record_device_attributes
        project = Project.find(params[:project_id])
        device_user = DeviceUser.find_by_id(params[:response][:device_user_id]) if params[:response][:device_user_id]
        project.device_users << device_user if device_user && !project.device_users.include?(device_user)
        device = @response.survey.device if @response.survey
        device_user.devices << device if device && !device_user.devices.include?(device)
      end
    end
  end
end