# frozen_string_literal: true

class Api::V4::QuestionsController < Api::V4::ApiController
  respond_to :json

  def index
    @questions = Question.all.includes(:question_set, :folder)
    render partial: 'api/v4/questions/index.json'
  end

  def show
    @question = Question.includes(:question_set, :folder).find(params[:id])
    render partial: 'api/v4/questions/show.json'
  end

  def copy
    question = Question.find(params[:id])
    new_question = question.copy
    redirect_to action: 'show', id: new_question.id
  end
end
