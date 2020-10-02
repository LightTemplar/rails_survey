# frozen_string_literal: true

module Api
  module V2
    class SurveysController < Api::V2::ApiController
      respond_to :json
      before_action :set_survey, only: %i[update destroy]

      def index
        @surveys = current_device_user.ongoing_surveys.includes(:instrument, :responses)
      end

      def create
        survey = Survey.new(survey_params)
        if survey.save
          render json: survey, status: :created
        else
          render json: { errors: survey.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @survey.update_attributes(survey_params)
          render json: @survey, status: :accepted
        else
          render json: { errors: @survey.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        respond_with @survey.destroy
      end

      private

      def set_survey
        project = Project.find(params[:project_id])
        instrument = project.instruments.find(params[:instrument_id])
        @survey = instrument.surveys.find(params[:id])
      end

      def survey_params
        params.require(:survey).permit(:instrument_id, :instrument_version_number,
                                       :uuid, :instrument_title, :device_user_id,
                                       :language, :metadata, :completed,
                                       :skipped_questions)
      end
    end
  end
end
