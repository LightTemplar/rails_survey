module Api
  module V1
    class GridsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @grids = project.grids
      end

      def show
        project = Project.find(params[:project_id])
        @grid = project.grids.find(params[:id])
      end
    end
  end
end
