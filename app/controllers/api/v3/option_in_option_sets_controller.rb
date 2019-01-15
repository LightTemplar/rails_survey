module Api
  module V3
    class OptionInOptionSetsController < Api::V1::OptionsController
      include Syncable
      respond_to :json

      def index
        @project = Project.find(params[:project_id])
        @option_in_option_sets = to_sync(@project.api_option_in_option_sets, 'option_in_option_sets', params[:last_sync_time])
      end
    end
  end
end
