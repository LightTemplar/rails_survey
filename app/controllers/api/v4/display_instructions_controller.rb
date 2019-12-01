# frozen_string_literal: true

class Api::V4::DisplayInstructionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_display

  def index
    @display_instructions = @display.display_instructions
  end

  def create
    display_instruction = @display.display_instructions.new(display_instruction_params)
    if display_instruction.save
      render json: display_instruction, status: :created
    else
      render json: { errors: display_instruction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    display_instruction = @display.display_instructions.find(params[:id])
    respond_with display_instruction.update_attributes(display_instruction_params)
  end

  def destroy
    display_instruction = @display.display_instructions.find(params[:id])
    respond_with display_instruction.destroy
  end

  private

  def set_display
    project = current_user.projects.find(params[:project_id])
    instrument = project.instruments.find(params[:instrument_id])
    @display = instrument.displays.find(params[:display_id])
  end

  def display_instruction_params
    params.require(:display_instruction).permit(:instruction_id, :position, :display_id)
  end
end
