# frozen_string_literal: true

class Api::V4::SubdomainTranslationsController < Api::V4::ApiController
  respond_to :json
  before_action :set_domain
  before_action :set_subdomain_translation, only: %i[update destroy]

  def index
    @subdomain_translations = @domain.subdomain_translations.where(language: params[:language])
  end

  def create
    subdomain_translation = @domain.subdomain_translations.new(subdomain_translations_params)
    if subdomain_translation.save
      render json: subdomain_translation, status: :created
    else
      render json: { errors: subdomain_translation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @subdomain_translation.update_attributes(subdomain_translations_params)
  end

  def destroy
    respond_with @subdomain_translation.destroy
  end

  private

  def set_domain
    project = Project.find(params[:project_id])
    instrument = project.instruments.find(params[:instrument_id])
    score_scheme = instrument.score_schemes.find(params[:score_scheme_id])
    @domain = score_scheme.domains.find(params[:domain_id])
  end

  def set_subdomain_translation
    @subdomain_translation = @domain.subdomain_translations.find(params[:id])
  end

  def subdomain_translations_params
    params.require(:subdomain_translation).permit(:subdomain_id, :text, :language)
  end
end
