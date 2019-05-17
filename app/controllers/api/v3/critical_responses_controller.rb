# frozen_string_literal: true

module Api
  module V3
    class CriticalResponsesController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @critical_responses = to_sync(@project.critical_responses, 'critical_responses', params[:last_sync_time])
      end
    end
  end
end
