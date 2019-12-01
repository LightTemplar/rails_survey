# frozen_string_literal: true

class Api::V4::SectionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instrument, only: %i[index show create update destroy]
  before_action :set_section, only: %i[update destroy]

  def index
    @sections = @instrument.sections.includes(:displays)
  end

  def show
    @section = @instrument.sections.includes(:displays).find(params[:id])
  end

  def create
    section = @instrument.sections.new(section_params)
    if section.save
      @section = @instrument.sections.includes(:displays).find(section.id)
      render 'show'
    else
      render json: { errors: section.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @section.update_attributes(section_params)
      render 'show'
    else
      render json: { errors: @section.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @section.destroy
  end

  private

  def section_params
    params.require(:section).permit(:title, :instrument_id, :position)
  end

  def set_instrument
    project = current_user.projects.find(params[:project_id])
    @instrument = project.instruments.find(params[:instrument_id])
  end

  def set_section
    @section = @instrument.sections.includes(:displays).find(params[:id])
  end
end
