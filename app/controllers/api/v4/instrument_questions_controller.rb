# frozen_string_literal: true

class Api::V4::InstrumentQuestionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instrument_project
  before_action :set_instrument_question, only: %i[update destroy]

  def index
    @instrument_questions = @instrument.instrument_questions
    render partial: 'api/v4/instrument_questions/index.json'
  end

  def create
    if bulk_create
      head :ok
    else
      render json: { errors: 'creation did not succeed' }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @instrument_question.update_attributes(instrument_question_params)
  end

  def destroy
    respond_with @instrument_question.destroy
  end

  private

  def set_instrument_project
    @project = Project.find(params[:project_id])
    @instrument = @project.instruments.find(params[:instrument_id])
  end

  def set_instrument_question
    @instrument_question = @instrument.instrument_questions.find(params[:id])
  end

  def instrument_question_params
    params.require(:instrument_question).permit(:instrument_id, :question_id, :number_in_instrument,
                                                :display_id, :identifier, :table_identifier)
  end

  def bulk_create
    ActiveRecord::Base.transaction do
      params[:instrument_question][:instrument_questions].map do |iq_params|
        iq = @instrument.instrument_questions.new(iq_params.permit(:instrument_id, :question_id, :number_in_instrument,
                                                                   :display_id, :identifier))
        iq.identifier = "#{iq_params[:identifier]}_#{iq_params[:number_in_instrument]}" if @instrument.instrument_questions.find_by_identifier(iq_params[:identifier])
        iq.save!
      end
    end
  end
end
