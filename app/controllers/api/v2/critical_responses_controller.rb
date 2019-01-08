module Api
  module V2
    class CriticalResponsesController < ApiApplicationController
      respond_to :json

      def index
        question = Question.find(params[:question_id])
        respond_with question.critical_responses
      end

      def create
        critical_response = CriticalResponse.new(critical_response_params)
        if critical_response.save
          render json: critical_response, status: :created
        else
          render json: { errors: critical_response.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        critical_response = CriticalResponse.find(params[:id])
        respond_with critical_response.update_attributes(critical_response_params)
      end

      def destroy
        critical_response = CriticalResponse.find(params[:id])
        respond_with critical_response.destroy
      end

      private
      def critical_response_params
        params.require(:critical_response).permit(:question_identifier, :option_identifier, :instruction_id)
      end
    end
  end
end
