module Api
  module V1
    module Frontend
      class InstrumentTranslationsController < ApiApplicationController
        respond_to :json

        def index
          instrument = current_project.instruments.find params[:instrument_id]
          @instrument_translations = instrument.translations if current_user
        end

        def show
          instrument = current_project.instruments.find params[:instrument_id]
          @instrument_translation = instrument.translations.find(params[:id]) if current_user
        end
      end
    end
  end
end
