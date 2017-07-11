module Api
  module V1
    module Frontend
      class GridTranslationsController < ApiApplicationController
        respond_to :json

        def create
          instrument_translation = InstrumentTranslation.find params[:instrument_translation_id]
          grid_translation = instrument_translation.grid_translations.new(grid_translation_params)
          if grid_translation.save
            render json: grid_translation, status: :created
          else
            render nothing: true, status: :unprocessable_entity
          end
        end

        def update
          instrument_translation = InstrumentTranslation.find params[:instrument_translation_id]
          grid_translation = instrument_translation.grid_translations.find params[:id]
          respond_with grid_translation.update_attributes(grid_translation_params)
        end

        private

        def grid_translation_params
          params.require(:grid_translation).permit(:grid_id, :instrument_translation_id, :instructions, :name)
        end
      end
    end
  end
end
