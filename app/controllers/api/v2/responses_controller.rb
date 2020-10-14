# frozen_string_literal: true

module Api
  module V2
    class ResponsesController < Api::V2::ApiController
      respond_to :json
      before_action :set_survey, only: %i[update create]

      def create
        response = @survey.responses.new(response_params)
        if response.save
          render json: response, status: :created
        else
          render json: { errors: response.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        response = @survey.responses.find(params[:id])
        if response.update_attributes(response_params)
          render json: response, status: :accepted
        else
          render json: { errors: response.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_survey
        project = Project.find(params[:project_id])
        instrument = project.instruments.find(params[:instrument_id])
        @survey = instrument.surveys.find(params[:survey_id])
      end

      def response_params
        params.require(:response).permit(:uuid, :survey_uuid, :question_identifier,
                                         :question_id, :text, :special_response,
                                         :other_response, :other_text, :time_started,
                                         :time_ended, :device_user_id)
      end
    end
  end
end
