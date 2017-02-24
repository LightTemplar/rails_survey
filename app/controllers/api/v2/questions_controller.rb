module Api
  module V2
    class QuestionsController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.paranoid_synch_models('questions', params[:last_sync_time])
      end

    end
  end
end