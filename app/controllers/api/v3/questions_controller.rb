module Api
  module V3
    class QuestionsController < Api::V1::QuestionsController
      # include Syncable
      respond_to :json

      def index
        @project = Project.find(params[:project_id])
        # @questions = to_sync(@project.questions, 'questions', params[:last_sync_time])
        @questions = @project.api_instrument_questions
        # @question_translations = @project.question_translations
      end
    end
  end
end
