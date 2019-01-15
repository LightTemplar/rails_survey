module Api
  module V3
    class ConditionSkipsController < Api::V1::ApiApplicationController
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @condition_skips = @project.condition_skips
      end
    end
  end
end
