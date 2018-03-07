module Api
  module V3
    class OptionInOptionSetsController < Api::V1::OptionsController
      respond_to :json

      def index
        @project = Project.find(params[:project_id])
        @option_in_option_sets = (@project.option_in_option_sets.uniq +
        @project.special_option_sets.map(&:option_in_option_sets)).flatten.compact
      end
    end
  end
end
