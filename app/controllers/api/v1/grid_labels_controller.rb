module Api
  module V1
    class GridLabelsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @grid_labels = project.grid_labels
      end

      def show
        project = Project.find(params[:project_id])
        @grid_label = project.grid_labels.find(params[:id])
      end
    end
  end
end
