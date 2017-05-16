module Api
  module V1
    class RandomizedFactorsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @randomized_factors = project.randomized_factors
      end

      def show
        project = Project.find(params[:project_id])
        @randomized_factor = project.randomized_factors.find(params[:id])
      end
    end
  end
end
