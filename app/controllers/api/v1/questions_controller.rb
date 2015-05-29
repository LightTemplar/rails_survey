module Api
  module V1
    class QuestionsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        questions = project.questions_to_sync(params[:instrument_versions]) 
        respond_with questions, include: :translations
      end

      def show
        respond_with Question.find(params[:id])
      end
    end
  end
end
