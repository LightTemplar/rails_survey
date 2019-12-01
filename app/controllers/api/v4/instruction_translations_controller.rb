# frozen_string_literal: true

class Api::V4::InstructionTranslationsController < Api::V4::ApiController
  respond_to :json
  before_action :set_instruction_translation, only: %i[update destroy]

  def index
    @instruction_translations = InstructionTranslation.where(language: params[:language])
  end

  def create
    instruction_translation = InstructionTranslation.new(instruction_translations_params)
    if instruction_translation.save
      render json: instruction_translation, status: :created
    else
      render json: { errors: instruction_translation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @instruction_translation.update_attributes(instruction_translations_params)
  end

  def destroy
    respond_with @instruction_translation.destroy
  end

  private

  def set_instruction_translation
    @instruction_translation = InstructionTranslation.find params[:id]
  end

  def instruction_translations_params
    params.require(:instruction_translation).permit(:instruction_id, :text, :language)
  end
end
