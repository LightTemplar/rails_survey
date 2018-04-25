module Api
  module V2
    class QuestionTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if !params[:language].blank? && !params[:question_set_id].blank?
          question_set = QuestionSet.find params[:question_set_id]
          @question_translations = question_set.translations.where(language: params[:language])
        elsif !params[:language].blank? && !params[:instrument_id].blank?
          instrument = Instrument.find params[:instrument_id]
          @question_translations = instrument.question_translations.where(language: params[:language])
        elsif !params[:language].blank?
          @question_translations = QuestionTranslation.where(language: params[:language])
        else
          @question_translations = QuestionTranslation.all
        end
      end

      def show
        @question_translation = QuestionTranslation.find params[:id]
      end

      def create
        question_translation = QuestionTranslation.new(question_translations_params)
        if question_translation.save
          render json: question_translation, status: :created
        else
          render json: { errors: question_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        question_translation = QuestionTranslation.find params[:id]
        respond_with question_translation.update_attributes(question_translations_params)
      end

      def batch_update
        translations = []
        ActiveRecord::Base.transaction do
          params[:question_translations].each do |translation_params|
            if translation_params[:id]
              qt = QuestionTranslation.find(translation_params[:id])
              translations << qt if qt.update_attributes(translation_params.permit(:question_id, :text, :language))
            elsif !translation_params[:text].blank?
              qt = QuestionTranslation.new(translation_params.permit(:question_id, :text, :language))
              translations << qt if qt.save
            end
          end
        end
        render json: :translations, status: :ok
      end

      private

      def question_translations_params
        params.require(:question_translation).permit(:question_id, :text, :language)
      end
    end
  end
end
