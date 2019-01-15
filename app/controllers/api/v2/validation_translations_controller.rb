module Api
  module V2
    class ValidationTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if !params[:language].blank? && !params[:validation_id].blank?
          validation = Validation.find(params[:validation_id])
          respond_with validation.validation_translations.where(language: params[:language])
        elsif !params[:language].blank?
          respond_with ValidationTranslation.where(language: params[:language])
        else
          respond_with ValidationTranslation.all
        end
      end

      def create
        validation_translation = ValidationTranslation.new(validation_translations_params)
        if validation_translation.save
          render json: validation_translation, status: :created
        else
          render json: { errors: validation_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        validation_translation = ValidationTranslation.find params[:id]
        respond_with validation_translation.update_attributes(validation_translations_params)
      end

      def batch_update
        translations = []
        ActiveRecord::Base.transaction do
          params[:validation_translations].each do |translation_params|
            if translation_params[:id]
              it = ValidationTranslation.find(translation_params[:id])
              translations << it if it.update_attributes(translation_params.permit(:validation_id, :text, :language))
            elsif !translation_params[:text].blank?
              it = ValidationTranslation.new(translation_params.permit(:validation_id, :text, :language))
              translations << it if it.save
            end
          end
        end
        render json: :translations, status: :ok
      end

      private

      def validation_translations_params
        params.require(:validation_translation).permit(:validation_id, :text, :language)
      end
    end
  end
end
