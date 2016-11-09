module Api
  module V2
    class QuestionsController < ApiApplicationController
      include Syncable

      def index
        project = Project.find(params[:project_id])
        questions = to_sync(project.questions.includes(:instrument), 'questions', params[:last_sync_time])
        render json: questions.includes(:translations)
      end

      def show
        render json: Question.find(params[:id])
      end
    end
  end
end