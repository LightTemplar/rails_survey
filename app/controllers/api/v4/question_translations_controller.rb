# frozen_string_literal: true

class Api::V4::QuestionTranslationsController < Api::V4::ApiController
  respond_to :json
  before_action :set_question_translation, only: %i[update destroy]

  def index
    @question_translations = QuestionTranslation.where(language: params[:language])
  end

  def create
    question_translation = QuestionTranslation.new(question_translations_params)
    if question_translation.save
      render json: question_translation, status: :created
    else
      render json: { errors: question_translation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @question_translation.update_attributes(question_translations_params)
  end

  def destroy
    respond_with @question_translation.destroy
  end

  private

  def set_question_translation
    @question_translation = QuestionTranslation.find params[:id]
  end

  def question_translations_params
    params.require(:question_translation).permit(:question_id, :text, :language)
  end
end
