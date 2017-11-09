module Api
  module V2
    class DisplaysController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_project

      def index
        @displays = @instrument.displays.order(:position).includes(:instrument_questions)
      end

      # def show
      #   @instrument_question = @instrument.instrument_questions.find(params[:id])
      # end

      # def create
      #   instrument_question = @instrument.instrument_questions.new(instrument_question_params)
      #   if instrument_question.save
      #     render json: instrument_question, status: :created
      #   else
      #     render json: { errors: instrument_question.errors.full_messages }, status: :unprocessable_entity
      #   end
      # end

      # def update
      #   instrument_question = @instrument.instrument_questions.find(params[:id])
      #   respond_with instrument_question.update_attributes(instrument_question_params)
      # end

      # def destroy
      #   instrument_question = @instrument.instrument_questions.find(params[:id])
      #   if instrument_question.destroy
      #     render nothing: true, status: :ok
      #   else
      #     render json: { errors: instrument_question.errors.full_messages }, status: :unprocessable_entity
      #   end
      # end

      private

      def set_instrument_project
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
      end

      def display_params
        params.require(:display).permit(:instrument_id, :position, :mode)
      end
    end
  end
end
