module Api
  module V2
    class MultipleSkipsController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_question

      def index
        @multiple_skips = @instrument_question.multiple_skips
      end

      def create
        multiple_skip = @instrument_question.multiple_skips.new(multiple_skip_params)
        if multiple_skip.save
          render json: multiple_skip, status: :created
        else
          render json: { errors: multiple_skip.errors.full_messages },
          status: :unprocessable_entity
        end
      end

      def update
        multiple_skip = @instrument_question.multiple_skips.find(params[:id])
        respond_with multiple_skip.update_attributes(multiple_skip_params)
      end

      def destroy
        multiple_skip = @instrument_question.multiple_skips.find(params[:id])
        if multiple_skip.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: multiple_skip.errors.full_messages },
          status: :unprocessable_entity
        end
      end

      private

      def set_instrument_question
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
        @instrument_question = @instrument.instrument_questions.find(params[:instrument_question_id])
      end

      def multiple_skip_params
        params.require(:multiple_skip).permit(:question_identifier, :value,
          :option_identifier, :skip_question_identifier, :instrument_question_id)
      end
    end
  end
end
