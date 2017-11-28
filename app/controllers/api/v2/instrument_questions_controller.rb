module Api
  module V2
    class InstrumentQuestionsController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_project

      def index
        @instrument_questions = @instrument.instrument_questions.order(:number_in_instrument)
      end

      def show
        @instrument_question = @instrument.instrument_questions.find(params[:id])
      end

      def create
        instrument_question = @instrument.instrument_questions.new(instrument_question_params)
        if instrument_question.save
          render json: instrument_question, status: :created
        else
          render json: { errors: instrument_question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        instrument_question = @instrument.instrument_questions.find(params[:id])
        respond_with instrument_question.update_attributes(instrument_question_params)
      end

      def destroy
        instrument_question = @instrument.instrument_questions.find(params[:id])
        if instrument_question.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: instrument_question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_instrument_project
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
      end

      def instrument_question_params
        params.require(:instrument_question).permit(:instrument_id, :question_id,
          :number_in_instrument, :display_type, :display_id)
      end
    end
  end
end
