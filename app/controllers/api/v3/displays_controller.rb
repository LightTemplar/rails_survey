module Api
  module V3
    class DisplaysController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find params[:project_id]
        instrument_ids = project.instruments.where(published: true).pluck(:id)
        @displays = to_sync(project.displays.where(instrument_id: instrument_ids), 'displays', params[:last_sync_time])
      end
    end
  end
end
