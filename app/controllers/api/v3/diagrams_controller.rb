# frozen_string_literal: true

module Api
  module V3
    class DiagramsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @diagrams = to_sync(@project.diagrams, 'diagrams', params[:last_sync_time])
      end
    end
  end
end
