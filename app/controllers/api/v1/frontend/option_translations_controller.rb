module Api
  module V1
    module Frontend
      class OptionTranslationsController < ApiApplicationController
        respond_to :json

        def update
          option = current_project.options.find(params[:option_id])
          translation = option.translations.find(params[:id])
          respond_with translation.update_attributes(option_translation_params)
        end

        private

        def option_translation_params
          params.require(:option_translation).permit(:text, :language, :option_changed)
        end
      end
    end
  end
end
