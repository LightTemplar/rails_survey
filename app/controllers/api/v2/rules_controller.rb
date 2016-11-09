module Api
  module V2
    class RulesController < ApiApplicationController
      include Syncable

      def index
        project = Project.find(params[:project_id])
        rules = to_sync(project.rules, 'rules', params[:last_sync_time])
        render json: rules
      end
    end 
  end
end
