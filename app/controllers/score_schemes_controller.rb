class ScoreSchemesController < ApplicationController
  before_action :set_scheme, only: [:show, :edit, :update, :destroy]

  def index
    @schemes = current_project.score_schemes
  end

  def show; end

  def edit; end

  def update
    if @scheme.update(scheme_params)
      redirect_to project_score_scheme_path(current_project, @scheme), notice: 'Score scheme was successfully updated'
    else
      render action: :edit
    end
  end

  def score
    survey = current_project.surveys.find(params[:survey_id])
    scheme = current_project.score_schemes.find(params[:id])
    scheme.score_survey(survey)
    redirect_to project_scores_path
  end

  private

  def set_scheme
    @scheme = current_project.score_schemes.find params[:id]
  end

  def scheme_params
    params.require(:score_scheme).permit(:title)
  end
end
