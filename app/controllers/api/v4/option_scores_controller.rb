# frozen_string_literal: true

class Api::V4::OptionScoresController < Api::V4::ApiController
  respond_to :json
  before_action :set_score_scheme
  before_action :set_option_score, only: %i[update destroy]

  def create
    option_score = OptionScore.new(option_score_params)
    if option_score.save
      render json: option_score, status: :created
    else
      render json: { errors: option_score.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @option_score.update_attributes(option_score_params)
  end

  def destroy
    respond_with @option_score.destroy
  end

  private

  def option_score_params
    params.require(:option_score).permit(:score_unit_question_id, :option_identifier, :value)
  end

  def set_score_scheme
    instrument = current_user.instruments.find(params[:instrument_id])
    @score_scheme = instrument.score_schemes.find(params[:score_scheme_id])
  end

  def set_option_score
    @option_score = @score_scheme.option_scores.find(params[:id])
  end
end
