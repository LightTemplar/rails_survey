module Api
  module V3
    class OptionSetsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @option_sets = to_sync(@project.api_option_sets, 'option_sets', params[:last_sync_time])
      end
    end
  end
end
