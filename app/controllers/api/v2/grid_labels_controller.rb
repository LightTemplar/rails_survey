module Api
  module V2
    class GridLabelsController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.synch_models('grid_labels', params[:last_sync_time])
      end
      
    end 
  end
end