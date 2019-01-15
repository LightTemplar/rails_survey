module Api
  module V4
    class InstrumentsController < Api::V1::ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @instruments = project.instruments.published
      end

      def show
        project = Project.find(params[:project_id])
        @instrument = project.instruments.find(params[:id])
      end
    end
  end
end
