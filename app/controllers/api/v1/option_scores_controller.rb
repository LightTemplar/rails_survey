module Api
  module V1
    class OptionScoresController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @option_scores = project.option_scores
      end

    end
  end
end
