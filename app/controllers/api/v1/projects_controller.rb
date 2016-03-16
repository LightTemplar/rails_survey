module Api
  module V1
    class ProjectsController < ApiApplicationController
      respond_to :json

      def index
        respond_with Project.all
      end

      def current_time
        respond_with Time.now.utc
      end

      def show
        respond_with Project.find(params[:id])
      end
    end
  end
end
