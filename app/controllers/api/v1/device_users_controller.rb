module Api
  module V1
    class DeviceUsersController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @device_users = project.device_users
      end

      def show
        project = Project.find(params[:project_id])
        @device_user = project.device_users.find(params[:id])
      end
    end
  end
end
