module Api
  module V2
    class InstrumentsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find params[:project_id]
        respond_with project.instruments.order('title') if current_user && project
      end

      def show
        project = Project.find params[:project_id]
        respond_with project.instruments.find(params[:id]) if current_user && project
      end
    end
  end
end
