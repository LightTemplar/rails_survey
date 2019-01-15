module Api
  module V3
    class MultipleSkipsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @multiple_skips = to_sync(@project.multiple_skips, 'multiple_skips', params[:last_sync_time])
      end
    end
  end
end
