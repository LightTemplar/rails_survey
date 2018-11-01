module Api
  module V2
    class LoopQuestionsController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_question

      def index
        @loop_questions = @instrument_question.loop_questions
      end

      def create
        loop_question = @instrument_question.loop_questions.new(loop_question_params)
        if loop_question.save
          render json: loop_question, status: :created
        else
          render json: { errors: loop_question.errors.full_messages },
          status: :unprocessable_entity
        end
      end

      def destroy
        loop_question = @instrument_question.loop_questions.find(params[:id])
        if loop_question.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: loop_question.errors.full_messages },
          status: :unprocessable_entity
        end
      end

      private

      def set_instrument_question
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
        @instrument_question = @instrument.instrument_questions.find(params[:instrument_question_id])
      end

      def loop_question_params
        params.require(:loop_question).permit(:instrument_question_id, :parent, :looped)
      end
    end
  end
end
