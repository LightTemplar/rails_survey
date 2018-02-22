module Api
  module V3
    class FollowUpQuestionsController < Api::V1::ApiApplicationController
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @follow_up_questions = @project.follow_up_questions
      end
    end
  end
end
