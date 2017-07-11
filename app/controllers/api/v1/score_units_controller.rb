module Api
  module V1
    class ScoreUnitsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @score_units = project.score_units
      end

    end
  end
end
