module Api
  module V1
    class QuestionsController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        @project = Project.find(params[:project_id])
        @questions = to_sync(@project.questions, 'questions', params[:last_sync_time])
      end

      def show
        project = Project.find(params[:project_id])
        @question = project.questions.find(params[:id])
      end
    end
  end
end
