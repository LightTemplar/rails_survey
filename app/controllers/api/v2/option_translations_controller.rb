module Api
  module V2
    class OptionTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if !params[:language].blank? && !params[:option_set_id].blank?
          option_set = OptionSet.find params[:option_set_id]
          respond_with option_set.translations.where(language: params[:language])
        elsif !params[:language].blank? && !params[:instrument_id].blank?
          instrument = Instrument.find(params[:instrument_id])
          respond_with instrument.option_translations.where(language: params[:language])
        elsif !params[:language].blank?
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

      def batch_update
        translations = []
        ActiveRecord::Base.transaction do
          params[:option_translations].each do |translation_params|
            if translation_params[:id]
              ot = OptionTranslation.find(translation_params[:id])
              translations << ot if ot.update_attributes(translation_params.permit(:option_id, :text, :language))
            elsif !translation_params[:text].blank?
              ot = OptionTranslation.new(translation_params.permit(:option_id, :text, :language))
              translations << ot if ot.save
            end
          end
        end
        render json: :translations, status: :ok
      end

      private
      def option_translations_params
        params.require(:option_translation).permit(:option_id, :text, :language)
      end
    end
  end
end
