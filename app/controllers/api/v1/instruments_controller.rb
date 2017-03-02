module Api
  module V1
    class InstrumentsController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @instruments = to_sync(project.instruments, 'instruments', params[:last_sync_time])
      end

      def show
        project = Project.find(params[:project_id])
        @instrument = project.instruments.find(params[:id])
      end
    end
  end
end
