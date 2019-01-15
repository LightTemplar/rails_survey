module Api
  module V3
    class ValidationsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find params[:project_id]
        @validations = to_sync(project.api_validations, 'validations', params[:last_sync_time])
      end
    end
  end
end
