module Api
  module V2
    class FollowUpQuestionsController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_question

      def index
        @follow_up_questions = @instrument_question.follow_up_questions
      end

      def create
        follow_up_question = @instrument_question.follow_up_questions.new(follow_up_question_params)
        if follow_up_question.save
          render json: follow_up_question, status: :created
        else
          render json: { errors: follow_up_question.errors.full_messages },
          status: :unprocessable_entity
        end
      end

      def update
        follow_up_question = @instrument_question.follow_up_questions.find(params[:id])
        respond_with follow_up_question.update_attributes(follow_up_question_params)
      end

      def destroy
        follow_up_question = @instrument_question.follow_up_questions.find(params[:id])
        if follow_up_question.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: follow_up_question.errors.full_messages },
          status: :unprocessable_entity
        end
      end

      private

      def set_instrument_question
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
        @instrument_question = @instrument.instrument_questions.find(params[:instrument_question_id])
      end

      def follow_up_question_params
        params.require(:follow_up_question).permit(:question_identifier,
          :instrument_question_id, :position, :following_up_question_identifier)
      end
    end
  end
end
