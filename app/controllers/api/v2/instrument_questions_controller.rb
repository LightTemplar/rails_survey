# frozen_string_literal: true

module Api
  module V2
    class InstrumentQuestionsController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_project
      before_action :set_instrument_question, only: %i[show update destroy]

      def index
        @instrument_questions = @instrument.instrument_questions.order('instrument_questions.number_in_instrument')
      end

      def show; end

      def create
        instrument_question = @instrument.instrument_questions.new(instrument_question_params)
        if instrument_question.save
          render json: instrument_question, status: :created
        else
          render json: { errors: instrument_question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        unless params[:country_list].blank?
          params[:instrument_question][:country_list] = params[:country_list]
          @instrument_question.touch
        end
        respond_with @instrument_question.update_attributes(instrument_question_params)
      end

      def destroy
        if @instrument_question.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: @instrument_question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_instrument_project
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
      end

      def set_instrument_question
        @instrument_question = @instrument.instrument_questions.find(params[:id])
      end

      def instrument_question_params
        params.require(:instrument_question).permit(:instrument_id, :question_id, :table_identifier,
                                                    :number_in_instrument, :display_type, :display_id,
                                                    :identifier, :country_list)
      end
    end
  end
end
