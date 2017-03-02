module Api
  module V1
    class SkipsController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @skips = to_sync(project.skips, 'skips', params[:last_sync_time])
      end

      def show
        project = Project.find(params[:project_id])
        @skip = project.skips.find(params[:id])
      end
    end
  end
end
