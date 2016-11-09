module Api
  module V2
    class ProjectsController < ApiApplicationController

      def index
        render json: Project.all
      end

      def show
        render json: Project.find(params[:id])
      end
    end
  end
end
