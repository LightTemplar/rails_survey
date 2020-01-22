# frozen_string_literal: true

class Api::V4::SurveyQuestionsController < Api::V4::ApiController
  respond_to :json

  def index
    @questions = Question.includes(:translations, options: [:translations]).where(id: params[:ids])
  end
end
