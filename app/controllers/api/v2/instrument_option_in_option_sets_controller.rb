module Api
  module V2
    class InstrumentOptionInOptionSetsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        instrument = project.instruments.find(params[:instrument_id])
        respond_with instrument.option_in_option_sets
      end

    end
  end
end
