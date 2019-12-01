# frozen_string_literal: true

class Api::V4::QuestionSetQuestionsController < Api::V4::ApiController
  respond_to :json

  def index
    question_set = QuestionSet.find(params[:question_set_id])
    @questions = question_set.questions
  end
end
