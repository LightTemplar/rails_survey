module Api
  module V1
    class ScoreSchemesController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @score_schemes = project.score_schemes
      end

    end
  end
end
