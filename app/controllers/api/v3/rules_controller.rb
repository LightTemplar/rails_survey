module Api
  module V3
    class RulesController < Api::V1::ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @instrument_rules = project.instrument_rules.with_deleted
      end
    end
  end
end
