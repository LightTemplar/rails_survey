# frozen_string_literal: true

module Api
  module V3
    class OptionsController < Api::V1::OptionsController
      respond_to :json

      def index
        @project = Project.find(params[:project_id])
        @options = to_sync(@project.api_options, 'options', params[:last_sync_time])
      end
    end
  end
end
