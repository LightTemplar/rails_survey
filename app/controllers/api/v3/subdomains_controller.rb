# frozen_string_literal: true

module Api
  module V3
    class SubdomainsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find params[:project_id]
        @subdomains = to_sync(project.subdomains, 'subdomains', params[:last_sync_time])
      end
    end
  end
end
