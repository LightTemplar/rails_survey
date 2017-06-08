module Api
  module V1
    class ScoreUnitQuestionsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @score_unit_questions = project.score_unit_questions
      end

    end
  end
end
