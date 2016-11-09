module Api
  module V2
    class GridLabelsController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.grid_labels
      end
      
    end 
  end
end