module Api
  module V2
    class OptionBackTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if !params[:language].blank? && !params[:option_set_id].blank? && !params[:option_id].blank?
          option_set = OptionSet.find params[:option_set_id]
          option = option_set.options.find(params[:option_id])
          option_translations = option.translations.where(language: params[:language])
          @option_back_translations = option_translation.back_translations.where(backtranslatable_id:
            option_translations.pluck(:id), language: params[:language]).uniq
        elsif !params[:language].blank? && !params[:option_set_id].blank?
          option_set = OptionSet.find params[:option_set_id]
          translations = option_set.translations.where(language: params[:language])
          @option_back_translations = BackTranslation.where(backtranslatable_type: 'OptionTranslation',
            backtranslatable_id: translations.pluck(:id), language: params[:language]).uniq
        elsif !params[:language].blank? && !params[:instrument_id].blank?
          instrument = Instrument.find params[:instrument_id]
          translations = instrument.option_translations.where(language: params[:language])
          @option_back_translations = BackTranslation.where(backtranslatable_type: 'OptionTranslation',
            backtranslatable_id: translations.pluck(:id), language: params[:language]).uniq
        elsif !params[:language].blank? && params[:option_set_id].blank?
          translations = OptionTranslation.where(language: params[:language])
          @option_back_translations = BackTranslation.where(backtranslatable_type: 'OptionTranslation',
            backtranslatable_id: translations.pluck(:id), language: params[:language]).uniq
        else
          @option_back_translations = BackTranslation.all.uniq
        end
      end

      def show
        @option_back_translation = BackTranslation.find params[:id]
      end

      def create
        option_back_translation = BackTranslation.new(option_back_translations_params)
        if option_back_translation.save
          render json: option_back_translation, status: :created
        else
          render json: { errors: option_back_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        option_back_translation = BackTranslation.find params[:id]
        respond_with option_back_translation.update_attributes(option_back_translations_params)
      end

      def batch_update
        translations = []
        ActiveRecord::Base.transaction do
          params[:option_back_translations].each do |translation_params|
            if translation_params[:id]
              qt = BackTranslation.find(translation_params[:id])
              translations << qt if qt.update_attributes(translation_params.permit(:text, :backtranslatable_id, :backtranslatable_type, :language, :approved))
            elsif !translation_params[:text].blank?
              qt = BackTranslation.new(translation_params.permit(:text, :backtranslatable_id, :backtranslatable_type, :language, :approved))
              translations << qt if qt.save
            end
          end
        end
        render json: :translations, status: :ok
      end

      private

      def option_back_translations_params
        params.require(:option_back_translation).permit(:text, :backtranslatable_id,
          :backtranslatable_type, :language, :approved)
      end
    end
  end
end
