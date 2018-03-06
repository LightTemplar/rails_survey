module Api
  module V3
    class OptionInOptionSetsController < Api::V1::OptionsController
      respond_to :json

      def index
        @project = Project.find(params[:project_id])
        @option_in_option_sets = @project.option_in_option_sets.uniq # Return unique records
      end
    end
  end
end
