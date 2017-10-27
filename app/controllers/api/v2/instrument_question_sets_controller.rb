module Api
  module V2
    class InstrumentQuestionSetsController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_project, only: [:index, :create, :destroy]

      def index
        respond_with @instrument.instrument_question_sets
      end

      def create
        iqs = @instrument.instrument_question_sets.new(instrument_question_set_params)
        if iqs.save
          render json: iqs, status: :created
        else
          render json: { errors: iqs.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        iqs = @instrument.instrument_question_sets.find(params[:id])
        respond_with iqs.update_attributes(instrument_question_set_params)
      end

      def destroy
        iqs = @instrument.instrument_question_sets.find(params[:id])
        if iqs.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: iqs.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_instrument_project
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
      end

      def instrument_question_set_params
        params.require(:instrument_question_set).permit(:instrument_id, :question_set_id)
      end
    end
  end
end
