class ScoreSchemesController < ApplicationController
  def index
    @schemes = current_project.score_schemes
  end

  def show
    @scheme = current_project.score_schemes.find params[:id]
  end

  def score
    survey = current_project.surveys.find(params[:survey_id])
    scheme = current_project.score_schemes.find(params[:id])
    scheme.score_survey(survey)
    redirect_to project_scores_path
  end
end
