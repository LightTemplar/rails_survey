# frozen_string_literal: true

module Api
  module V4
    class ResponsesController < Api::V4::ApiController
      respond_to :json

      def index
        survey = Survey.find params[:survey_id]
        @responses = survey.responses
      end
    end
  end
end
