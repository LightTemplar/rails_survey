module Api
  module V1
    module Frontend
      class InstrumentsController < ApiApplicationController
        respond_to :json

        def index
          @instruments = current_project.instruments.order('title') if current_user
        end

        def show
          @instrument = current_project.instruments.find(params[:id]) if current_user
        end
      end
    end
  end
end
