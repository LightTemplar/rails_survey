module Api
  module V3
    class ProjectsController < Api::V1::ApiApplicationController
      respond_to :json

      def index
        @projects = Project.all
      end

      def current_time
        respond_with Time.now.utc
      end

      def show
        respond_to Project.find(params[:id])
      end
    end
  end
end
