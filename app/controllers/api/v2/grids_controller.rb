module Api
  module V2
    class GridsController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.synch_models('grids', params[:last_sync_time])
      end
      
    end 
  end
end