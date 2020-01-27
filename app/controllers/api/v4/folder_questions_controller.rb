# frozen_string_literal: true

class Api::V4::FolderQuestionsController < Api::V4::ApiController
  respond_to :json
  before_action :set_folder
  before_action :set_question, only: %i[show update destroy]

  def index
    @questions = @folder.questions.includes(:question_set, :folder)
  end

  def show; end

  def create
    question = @folder.questions.new(question_params)
    if question.save
      render json: question, status: :created
    else
      render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @question.update_attributes(question_params)
      render json: @question, status: :accepted
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @question.destroy
  end

  private

  def set_folder
    question_set = QuestionSet.find(params[:question_set_id])
    @folder = question_set.folders.find(params[:folder_id])
  end

  def set_question
    @question = @folder.questions.where(id: params[:id]).first
    @question ||= Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:option_set_id, :question_set_id, :text, :question_type,
                                     :question_identifier, :parent_identifier, :identifies_survey,
                                     :instruction_id, :critical, :special_option_set_id, :folder_id,
                                     :validation_id, :rank_responses, :pdf_response_height,
                                     :pdf_print_options, :pop_up_instruction_id, :instruction_after_text,
                                     :default_response, :position)
  end
end
