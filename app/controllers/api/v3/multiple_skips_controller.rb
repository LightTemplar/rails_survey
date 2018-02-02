module Api
  module V3
    class MultipleSkipsController < Api::V1::ApiApplicationController
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @multiple_skips = @project.multiple_skips
      end
    end
  end
end
