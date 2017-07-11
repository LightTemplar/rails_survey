module Api
  module V1
    module Frontend
      class GridLabelTranslationsController < ApiApplicationController
        respond_to :json

        def create
          instrument_translation = InstrumentTranslation.find params[:instrument_translation_id]
          grid_label_translation = instrument_translation.grid_label_translations.new(grid_label_translation_params)
          if grid_label_translation.save
            render json: grid_label_translation, status: :created
          else
            render nothing: true, status: :unprocessable_entity
          end
        end

        def update
          instrument_translation = InstrumentTranslation.find params[:instrument_translation_id]
          grid_label_translation = instrument_translation.grid_label_translations.find params[:id]
          respond_with grid_label_translation.update_attributes(grid_label_translation_params)
        end

        private

        def grid_label_translation_params
          params.require(:grid_label_translation).permit(:grid_label_id, :instrument_translation_id, :label)
        end
      end
    end
  end
end
