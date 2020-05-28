# frozen_string_literal: true

module Api
  module V3
    class DomainsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find params[:project_id]
        @domains = to_sync(project.domains, 'domains', params[:last_sync_time])
      end
    end
  end
end
