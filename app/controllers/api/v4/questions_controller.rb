# frozen_string_literal: true

class Api::V4::QuestionsController < Api::V4::ApiController
  respond_to :json

  def index
    @questions = Question.all
  end
end
