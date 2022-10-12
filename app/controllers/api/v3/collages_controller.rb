# frozen_string_literal: true

module Api
  module V3
    class CollagesController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @collages = to_sync(@project.api_collages, 'collages', params[:last_sync_time])
      end
    end
  end
end
