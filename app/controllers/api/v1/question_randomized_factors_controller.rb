module Api
  module V1
    class QuestionRandomizedFactorsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @question_randomized_factors = project.question_randomized_factors
      end

      def show
        project = Project.find(params[:project_id])
        @question_randomized_factor = project.question_randomized_factors.find(params[:id])
      end
    end
  end
end
