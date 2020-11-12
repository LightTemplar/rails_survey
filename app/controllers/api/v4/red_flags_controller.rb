# frozen_string_literal: true

class Api::V4::RedFlagsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instrument_project
  before_action :set_instrument_question

  def index
    @red_flags = @instrument_question.red_flags
  end

  def create
    red_flag = @instrument_question.red_flags.new(red_flag_params)
    if red_flag.save
      render json: red_flag, status: :created
    else
      render json: { errors: red_flag.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    red_flag = @instrument_question.red_flags.find(params[:id])
    respond_with red_flag.update_attributes(red_flag_params)
  end

  def destroy
    red_flag = @instrument_question.red_flags.find(params[:id])
    if red_flag.destroy
      head :ok
    else
      render json: { errors: red_flag.errors.full_messages },
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

  def red_flag_params
    params.require(:red_flag).permit(:instruction_id, :selected, :option_identifier,
                                     :instrument_question_id)
  end
end
