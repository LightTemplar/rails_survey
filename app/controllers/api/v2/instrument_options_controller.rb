module Api
  module V2
    class InstrumentOptionsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        instrument = project.instruments.find(params[:instrument_id])
        respond_with instrument.options
      end

    end
  end
end
