module Api
  module V1
    class RandomizedOptionsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @options = project.randomized_options
      end

      def show
        project = Project.find(params[:project_id])
        @option = project.randomized_options.find(params[:id])
      end
    end
  end
end
