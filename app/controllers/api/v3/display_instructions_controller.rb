module Api
  module V3
    class DisplayInstructionsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find params[:project_id]
        @display_instructions = to_sync(project.api_display_instructions, 'display_instructions',
                                        params[:last_sync_time])
      end
    end
  end
end
