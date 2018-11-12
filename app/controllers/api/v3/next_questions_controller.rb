module Api
  module V3
    class NextQuestionsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @next_questions = to_sync(@project.next_questions, 'next_questions', params[:last_sync_time])
      end
    end
  end
end
