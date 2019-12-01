# frozen_string_literal: true

class Api::V4::OptionScoresController < Api::V4::ApiController
  respond_to :json
  before_action :set_score_scheme
  before_action :set_option_score, only: %i[destroy]

  def destroy
    respond_with @option_score.destroy
  end

  private

  def set_score_scheme
    instrument = current_user.instruments.find(params[:instrument_id])
    @score_scheme = instrument.score_schemes.find(params[:score_scheme_id])
  end

  def set_option_score
    @option_score = @score_scheme.option_scores.find(params[:id])
  end
end
