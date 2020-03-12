# frozen_string_literal: true

class Api::V4::ScoreUnitsController < Api::V4::ApiController
  respond_to :json
  before_action :set_subdomain, only: %i[index show create update destroy copy]
  before_action :set_score_unit, only: %i[update destroy copy]

  def index
    @score_units = @subdomain.score_units.includes(:option_scores)
  end

  def show
    @score_unit = @subdomain.score_units.find(params[:id])
  end

  def create
    score_unit = @subdomain.score_units.new(score_unit_params)
    if score_unit.save
      create_children(score_unit)
      render json: score_unit, status: :created
    else
      render json: { errors: score_unit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @score_unit.update_attributes(score_unit_params)
  end

  def copy
    new_score_unit = @score_unit.copy
    redirect_to action: 'show', id: new_score_unit.id
  end

  def destroy
    respond_with @score_unit.destroy
  end

  private

  def score_unit_params
    params.require(:score_unit).permit(:weight, :score_type, :subdomain_id,
                                       :title, :base_point_score)
  end

  def set_subdomain
    @instrument = current_user.instruments.find(params[:instrument_id])
    @score_scheme = @instrument.score_schemes.find(params[:score_scheme_id])
    @subdomain = @score_scheme.subdomains.find(params[:subdomain_id])
  end

  def set_score_unit
    @score_unit = @score_scheme.score_units.find(params[:id])
  end

  def create_children(score_unit)
    ActiveRecord::Base.transaction do
      params[:score_unit][:options].each do |option|
        suq = ScoreUnitQuestion.where(score_unit_id: score_unit.id,
                                      instrument_question_id: option[:instrument_question_id]).first_or_create!
        OptionScore.where(score_unit_question_id: suq.id, option_identifier:
          option[:option_identifier]).first_or_create!(value: option[:value],
                                                       follow_up_qid: option[:follow_up_qid],
                                                       position: option[:position])
      end
    end
  end
end
