module Api
  module V2
    class OptionsController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.paranoid_synch_models('options', params[:last_sync_time])
      end

    end
  end
end