# frozen_string_literal: true

class Api::V4::SectionTranslationsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instrument_project
  before_action :set_section_translation, only: %i[update destroy]

  def index
    @section_translations = @instrument.section_translations.where(language: params[:language])
  end

  def create
    section_translation = @instrument.section_translations.new(section_translations_params)
    if section_translation.save
      render json: section_translation, status: :created
    else
      render json: { errors: section_translation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @section_translation.update_attributes(section_translations_params)
  end

  def destroy
    respond_with @section_translation.destroy
  end

  private

  def set_instrument_project
    @project = Project.find(params[:project_id])
    @instrument = @project.instruments.find(params[:instrument_id])
  end

  def set_section_translation
    @section_translation = @instrument.section_translations.find params[:id]
  end

  def section_translations_params
    params.require(:section_translation).permit(:section_id, :text, :language)
  end
end
