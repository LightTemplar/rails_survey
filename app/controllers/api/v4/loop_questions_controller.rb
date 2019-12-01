# frozen_string_literal: true

class Api::V4::LoopQuestionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instrument_project
  before_action :set_instrument_question

  private

  def set_instrument_project
    project = Project.find(params[:project_id])
    @instrument = project.instruments.find(params[:instrument_id])
  end

  def set_instrument_question
    @instrument_question = @instrument.instrument_questions.find(params[:instrument_question_id])
  end
end
