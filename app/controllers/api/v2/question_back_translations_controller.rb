module Api
  module V2
    class QuestionBackTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if !params[:language].blank? && !params[:question_set_id].blank? && !params[:question_id].blank?
          question_set = QuestionSet.find params[:question_set_id]
          question = question_set.questions.find(params[:question_id])
          question_translations = question.translations.where(language: params[:language])
          @question_back_translations = question_translation.back_translations.where(backtranslatable_id:
            question_translations.pluck(:id), language: params[:language])
        elsif !params[:language].blank? && !params[:question_set_id].blank?
          question_set = QuestionSet.find params[:question_set_id]
          translations = question_set.translations.where(language: params[:language])
          @question_back_translations = BackTranslation.where(backtranslatable_type: 'QuestionTranslation',
            backtranslatable_id: translations.pluck(:id), language: params[:language])
        elsif !params[:language].blank? && !params[:instrument_id].blank?
          instrument = Instrument.find params[:instrument_id]
          translations = instrument.question_translations.where(language: params[:language])
          @question_back_translations = BackTranslation.where(backtranslatable_type: 'QuestionTranslation',
            backtranslatable_id: translations.pluck(:id), language: params[:language])
        elsif !params[:language].blank? && params[:question_set_id].blank?
          translations = QuestionTranslation.where(language: params[:language])
          @question_back_translations = BackTranslation.where(backtranslatable_type: 'QuestionTranslation',
            backtranslatable_id: translations.pluck(:id), language: params[:language])
        else
          @question_back_translations = BackTranslation.all
        end
      end

      def show
        @question_back_translation = BackTranslation.find params[:id]
      end

      def create
        question_back_translation = BackTranslation.new(question_back_translations_params)
        if question_back_translation.save
          render json: question_back_translation, status: :created
        else
          render json: { errors: question_back_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        question_back_translation = BackTranslation.find params[:id]
        respond_with question_back_translation.update_attributes(question_back_translations_params)
      end

      def batch_update
        translations = []
        ActiveRecord::Base.transaction do
          params[:question_back_translations].each do |translation_params|
            if translation_params[:id]
              qt = BackTranslation.find(translation_params[:id])
              translations << qt if qt.update_attributes(translation_params.permit(:text, :backtranslatable_id, :backtranslatable_type, :language))
            elsif !translation_params[:text].blank?
              qt = BackTranslation.new(translation_params.permit(:text, :backtranslatable_id, :backtranslatable_type, :language))
              translations << qt if qt.save
            end
          end
        end
        render json: :translations, status: :ok
      end

      private

      def question_back_translations_params
        params.require(:question_back_translation).permit(:text, :backtranslatable_id, :backtranslatable_type, :language)
      end
    end
  end
end
