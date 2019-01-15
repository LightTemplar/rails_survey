module Api
  module V3
    class QuestionsController < Api::V1::QuestionsController
      respond_to :json

      def index
        @project = Project.find(params[:project_id])
        @questions = to_sync(@project.api_instrument_questions, 'instrument_questions', params[:last_sync_time])
      end
    end
  end
end
