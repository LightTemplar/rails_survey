module Api
  module V2
    class InstrumentsController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.paranoid_synch_models('instruments', params[:last_sync_time])
      end

    end
  end
end