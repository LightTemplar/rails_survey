# frozen_string_literal: true

class Api::V4::FoldersController < Api::V4::ApiController
  respond_to :json
  before_action :set_question_set
  before_action :set_folder, only: %i[show update destroy]

  def index
    @folders = @question_set.folders
  end

  def show; end

  def create
    folder = @question_set.folders.new(folder_params)
    if folder.save
      render json: folder, status: :created
    else
      render json: { errors: folder.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    respond_with @folder.update_attributes(folder_params)
  end

  def destroy
    respond_with @folder.destroy
  end

  private

  def set_question_set
    @question_set = QuestionSet.find(params[:question_set_id])
  end

  def set_folder
    @folder = @question_set.folders.find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:question_set_id, :title)
  end
end
