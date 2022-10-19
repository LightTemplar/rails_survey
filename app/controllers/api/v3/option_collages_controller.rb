# frozen_string_literal: true

module Api
  module V3
    class OptionCollagesController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @option_collages = to_sync(@project.api_option_collages, 'option_collages', params[:last_sync_time])
      end
    end
  end
end
