module Api
  module V3
    class DisplaysController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find params[:project_id]
        @displays = to_sync(project.api_displays, 'displays', params[:last_sync_time])
      end
    end
  end
end
