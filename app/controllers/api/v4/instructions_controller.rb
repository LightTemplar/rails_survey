# frozen_string_literal: true

class Api::V4::InstructionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instruction, only: %i[update show destroy]

  def index
    @instructions = Instruction.all.order(updated_at: :desc)
  end

  def show; end

  def create
    instruction = Instruction.new(instruction_params)
    if instruction.save
      render json: instruction, status: :created
    else
      render json: { errors: instruction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @instruction.update_attributes(instruction_params)
      render json: @instruction, status: :accepted
    else
      render json: { errors: @instruction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @instruction.destroy
  end

  private

  def instruction_params
    params.require(:instruction).permit(:title, :text)
  end

  def set_instruction
    @instruction = Instruction.find(params[:id])
  end
end
