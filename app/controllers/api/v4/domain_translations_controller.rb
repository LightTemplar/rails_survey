# frozen_string_literal: true

class Api::V4::DomainTranslationsController < Api::V4::ApiController
  respond_to :json
  before_action :set_score_scheme
  before_action :set_domain_translation, only: %i[update destroy]

  def index
    @domain_translations = @score_scheme.domain_translations.where(language: params[:language])
  end

  def create
    domain_translation = @score_scheme.domain_translations.new(domain_translations_params)
    if domain_translation.save
      render json: domain_translation, status: :created
    else
      render json: { errors: domain_translation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @domain_translation.update_attributes(domain_translations_params)
  end

  def destroy
    respond_with @domain_translation.destroy
  end

  private

  def set_score_scheme
    project = Project.find(params[:project_id])
    instrument = project.instruments.find(params[:instrument_id])
    @score_scheme = instrument.score_schemes.find(params[:score_scheme_id])
  end

  def set_domain_translation
    @domain_translation = @score_scheme.domain_translations.find(params[:id])
  end

  def domain_translations_params
    params.require(:domain_translation).permit(:domain_id, :text, :language)
  end
end
