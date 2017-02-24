module Api
  module V2
    class DeviceUsersController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.synch_models('device_users', params[:last_sync_time])
      end

    end
  end
end
