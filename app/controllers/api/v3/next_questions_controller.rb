module Api
  module V3
    class NextQuestionsController < Api::V1::ApiApplicationController
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @next_questions = @project.next_questions
      end
    end
  end
end
