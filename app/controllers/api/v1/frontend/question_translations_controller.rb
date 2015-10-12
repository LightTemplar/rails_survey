module Api
  module V1
    module Frontend
      class QuestionTranslationsController < ApiApplicationController
        respond_to :json
        
        def update
           question = current_project.questions.find(params[:question_id])
           translation = question.translations.find(params[:id])
           respond_with translation.update_attributes(question_translation_params)
        end

        private
        def question_translation_params
          params.require(:question_translation).permit(:language, :text, :reg_ex_validation_message, :question_changed, :instructions)
        end
      end
    end
  end
end
