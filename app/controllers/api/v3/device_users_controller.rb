# frozen_string_literal: true

module Api
  module V3
    class DeviceUsersController < Api::V1::DeviceUsersController
      skip_before_action :restrict_access
      skip_before_action :check_version_code
      respond_to :json

      def create
        project = Project.find params[:project_id]
        device_user = project.device_users.find_by_username(params[:device_user][:username])
        if device_user&.authenticate(params[:device_user][:password])
          render json: device_user.api_key
        else
          render json: { success: false, info: 'Login failure', data: {} }, status: :unauthorized
        end
      end
    end
  end
end
