module Api
  module V2
    class SkipsController < ApiApplicationController
      include Syncable

      def index
        project = Project.find(params[:project_id])
        skips = to_sync(project.skips, 'skips', params[:last_sync_time])
        render json: skips
      end

      def show
        render json: Skip.find(params[:id])
      end

    end 
  end
end