module Api
  module V2
    class ProjectsController < ApiApplicationController
      respond_to :json

      def index
        respond_with current_user.projects
      end

      def show
        respond_with current_user.projects.find(params[:id])
      end
    end
  end
end
