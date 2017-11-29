module Api
  module V2
    class OptionTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if params[:language]
          respond_with OptionTranslation.where(language: params[:language])
        else
          respond_with OptionTranslation.all
        end
      end

      def create
        option_translation = OptionTranslation.new(option_translations_params)
        if option_translation.save
          render json: option_translation, status: :created
        else
          render json: { errors: option_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        option_translation = OptionTranslation.find params[:id]
        respond_with option_translation.update_attributes(option_translations_params)
      end

      private
      def option_translations_params
        params.require(:option_translation).permit(:option_id, :text, :language)
      end
    end
  end
end
