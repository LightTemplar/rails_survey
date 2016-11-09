module Api
  module V2
    class InstrumentsController < ApiApplicationController
      include Syncable

      def index
        project = Project.find(params[:project_id])
        instruments = to_sync(project.instruments, 'instruments', params[:last_sync_time])
        render json: instruments.includes(:translations)
      end

      def show
        project = Project.find(params[:project_id])
        render json: project.instruments.find(params[:id])
      end
    end
  end
end