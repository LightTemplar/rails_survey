module Api
  module V2
    class DeviceUsersController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.device_users
      end

      def show
        project = Project.find(params[:project_id])
        render json: project.device_users.find(params[:id])
      end
    end
  end
end
