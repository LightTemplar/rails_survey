module Api
  module V2
    class SkipsController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.paranoid_synch_models('skips', params[:last_sync_time])
      end

    end 
  end
end