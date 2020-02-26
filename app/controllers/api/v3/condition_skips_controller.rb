# frozen_string_literal: true

module Api
  module V3
    class ConditionSkipsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @condition_skips = to_sync(@project.condition_skips.includes(:instrument_question), 'condition_skips', params[:last_sync_time])
      end
    end
  end
end
