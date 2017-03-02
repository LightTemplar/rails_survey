module Api
  module V1
    class GridsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @grids = project.grids
      end
    end
  end
end
