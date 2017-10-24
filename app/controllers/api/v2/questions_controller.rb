module Api
  module V2
      class QuestionsController < ApiApplicationController
        respond_to :json
        before_action :set_question_set, only: [:index, :create, :update]

        def index
          respond_with @question_set.questions
        end

        def create
          question = @question_set.questions.new(question_params)
          if question.save
            render json: question, status: :created
          else
            render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          question = @question_set.questions.find(params[:id])
          respond_with question.update_attributes(question_params)
        end

        private

        def set_question_set
          @question_set = QuestionSet.find(params[:question_set_id])
        end

        def question_params
          params.require(:question).permit(:option_set_id, :question_set_id, :text, :question_type,
            :question_identifier, :follow_up_position, :following_up_question_identifier,
            :reg_ex_validation, :child_update_count, :reg_ex_validation_message,
            :identifies_survey, :grid_id, :instructions, :number_in_grid,
            :instrument_version_number, :critical)
        end
      end
  end
end
