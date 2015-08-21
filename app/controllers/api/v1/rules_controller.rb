module Api
  module V1
    class RulesController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        rules = to_sync(project.rules, 'rules', params[:last_sync_time])
        respond_with rules
      end
    end 
  end
end
