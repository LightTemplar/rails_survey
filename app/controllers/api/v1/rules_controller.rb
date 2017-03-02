module Api
  module V1
    class RulesController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @rules = to_sync(project.rules, 'rules', params[:last_sync_time])
      end
    end
  end
end
