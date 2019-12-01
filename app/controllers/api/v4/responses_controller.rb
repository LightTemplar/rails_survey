# frozen_string_literal: true

class Api::V4::ResponsesController < Api::V4::ApiController
  respond_to :json

  def index
    survey = Survey.find params[:survey_id]
    @responses = survey.responses
  end
end
