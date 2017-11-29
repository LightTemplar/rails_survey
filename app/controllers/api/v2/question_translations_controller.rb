module Api
  module V2
    class QuestionTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if params[:language]
          respond_with QuestionTranslation.where(language: params[:language])
        else
          respond_with QuestionTranslation.all
        end
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

      private

      def question_translations_params
        params.require(:question_translation).permit(:question_id, :text, :language)
      end
    end
  end
end
