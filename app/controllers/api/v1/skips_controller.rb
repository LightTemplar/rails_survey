module Api
  module V1
    class SkipsController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        skips = to_sync(project.skips, 'skips', params[:last_sync_time])
        respond_with skips
      end

      def show
        respond_with Skip.find(params[:id])
      end

    end 
  end
end