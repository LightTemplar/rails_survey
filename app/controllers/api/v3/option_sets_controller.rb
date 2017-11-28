module Api
  module V3
    class OptionSetsController < Api::V1::ApiApplicationController
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @option_sets = @project.option_sets
      end
    end
  end
end
