# frozen_string_literal: true

class Api::V4::NextQuestionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instrument_project
  before_action :set_instrument_question

  def index
    @next_questions = @instrument_question.next_questions
  end

  def create
    next_question = @instrument_question.next_questions.new(next_question_params)
    if next_question.save
      render json: next_question, status: :created
    else
      render json: { errors: next_question.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    next_question = @instrument_question.next_questions.find(params[:id])
    respond_with next_question.update_attributes(next_question_params)
  end

  def destroy
    next_question = @instrument_question.next_questions.find(params[:id])
    if next_question.destroy
      head :ok
    else
      render json: { errors: next_question.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def set_instrument_project
    project = Project.find(params[:project_id])
    @instrument = project.instruments.find(params[:instrument_id])
  end

  def set_instrument_question
    @instrument_question = @instrument.instrument_questions.find(params[:instrument_question_id])
  end

  def next_question_params
    params.require(:next_question).permit(:question_identifier, :value, :complete_survey,
                                          :option_identifier, :next_question_identifier, :instrument_question_id)
  end
end
