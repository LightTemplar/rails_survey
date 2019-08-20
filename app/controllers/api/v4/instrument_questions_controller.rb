# frozen_string_literal: true

module Api
  module V4
    class InstrumentQuestionsController < Api::V4::ApiController
      respond_to :json
      before_action :set_instrument_project
      before_action :set_instrument_question, only: %i[update destroy]

      def create
        if bulk_create
          render nothing: true, status: :created
        else
          render json: { errors: 'creation did not succeed' }, status: :unprocessable_entity
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
        params.require(:instrument_question).permit(:instrument_id, :question_id, :number_in_instrument,
                                                    :display_id, :identifier)
      end

      def bulk_create
        ActiveRecord::Base.transaction do
          params[:instrument_questions].map do |iq_params|
            iq = @instrument.instrument_questions.new(iq_params.permit(:instrument_id, :question_id,
                                                                       :number_in_instrument, :display_id, :identifier))
            iq.save!
          end
        end
      end
    end
  end
end
