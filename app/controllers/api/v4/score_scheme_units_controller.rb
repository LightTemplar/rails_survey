# frozen_string_literal: true

class Api::V4::ScoreSchemeUnitsController < Api::V4::ApiController
  respond_to :json

  def index
    instrument = current_user.instruments.find(params[:instrument_id])
    score_scheme = instrument.score_schemes.find(params[:score_scheme_id])
    @score_units = score_scheme.score_units.includes(:option_scores)
  end
end
