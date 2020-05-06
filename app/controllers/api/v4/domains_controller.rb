# frozen_string_literal: true

class Api::V4::DomainsController < Api::V4::ApiController
  respond_to :json
  before_action :set_score_scheme, only: %i[index show create update destroy]
  before_action :set_domain, only: %i[update destroy]

  def index
    @domains = @score_scheme.domains.includes(:subdomains).sort_by { |domain| domain.title.to_i }
  end

  def show
    @domain = @score_scheme.domains.includes(:subdomains).find(params[:id])
  end

  def create
    domain = @score_scheme.domains.new(domain_params)
    if domain.save
      render json: domain, status: :created
    else
      render json: { errors: domain.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @domain.update_attributes(domain_params)
  end

  def destroy
    respond_with @domain.destroy
  end

  private

  def domain_params
    params.require(:domain).permit(:title, :score_scheme_id, :name)
  end

  def set_score_scheme
    project = current_user.projects.find(params[:project_id])
    instrument = project.instruments.find(params[:instrument_id])
    @score_scheme = instrument.score_schemes.find(params[:score_scheme_id])
  end

  def set_domain
    @domain = @score_scheme.domains.find(params[:id])
  end
end
