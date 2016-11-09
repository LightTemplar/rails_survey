module Api
  module V2
    class GridsController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.grids
      end
      
    end 
  end
end