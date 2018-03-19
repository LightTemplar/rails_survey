module Api
  module V4
    class ProjectsController < Api::V1::ApiApplicationController
      respond_to :json

      def index
        @projects = Project.all
      end

      def show
        @project = Project.find(params[:id])
      end
    end
  end
end
