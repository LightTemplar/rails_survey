# frozen_string_literal: true

class Api::V4::ConditionSkipsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instrument_project
  before_action :set_instrument_question

  def index
    @condition_skips = @instrument_question.condition_skips
  end

  def create
    condition_skip = @instrument_question.condition_skips.new(condition_skip_params)
    if condition_skip.save
      render json: condition_skip, status: :created
    else
      render json: { errors: condition_skip.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    condition_skip = @instrument_question.condition_skips.find(params[:id])
    respond_with condition_skip.update_attributes(condition_skip_params)
  end

  def destroy
    condition_skip = @instrument_question.condition_skips.find(params[:id])
    if condition_skip.destroy
      head :ok
    else
      render json: { errors: condition_skip.errors.full_messages },
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

  def condition_skip_params
    params.require(:condition_skip).permit(:instrument_question_id, :question_identifier, :next_question_identifier,
                                           :question_identifiers, :option_ids, :values, :value_operators)
  end
end
