module Api
  module V1
    class GridLabelsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @grid_labels = project.grid_labels
      end
    end
  end
end
