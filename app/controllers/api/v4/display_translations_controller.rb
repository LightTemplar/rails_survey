# frozen_string_literal: true

class Api::V4::DisplayTranslationsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instrument_project
  before_action :set_display_translation, only: %i[update destroy]

  def index
    @display_translations = @instrument.display_translations.where(language: params[:language])
  end

  def create
    display_translation = @instrument.display_translations.new(display_translations_params)
    if display_translation.save
      render json: display_translation, status: :created
    else
      render json: { errors: display_translation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @display_translation.update_attributes(display_translations_params)
  end

  def destroy
    respond_with @display_translation.destroy
  end

  private

  def set_instrument_project
    @project = Project.find(params[:project_id])
    @instrument = @project.instruments.find(params[:instrument_id])
  end

  def set_display_translation
    @display_translation = @instrument.display_translations.find params[:id]
  end

  def display_translations_params
    params.require(:display_translation).permit(:display_id, :text, :language)
  end
end
