module Api
  module V3
    class InstructionsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find params[:project_id]
        @instructions = to_sync(project.api_instructions, 'instructions', params[:last_sync_time])
      end
    end
  end
end
