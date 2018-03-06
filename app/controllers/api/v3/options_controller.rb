module Api
  module V3
    class OptionsController < Api::V1::OptionsController
      respond_to :json

      def index
        @project = Project.find(params[:project_id])
        @options = @project.api_options.uniq # Return unique records
      end
    end
  end
end
