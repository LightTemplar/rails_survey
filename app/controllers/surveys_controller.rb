class SurveysController < ApplicationController
  after_action :verify_authorized
  
  def index
    if params[:roster_id]
      roster = current_project.rosters.find params[:roster_id]
      @surveys = roster.surveys.order('created_at DESC').page params[:page]
    else
      @surveys = current_project.surveys.non_roster.order('created_at DESC').page params[:page]
    end
    authorize @surveys
  end

  def show
    @survey = current_project.surveys.find(params[:id])
    authorize @survey
    @instrument_version = @survey.instrument_version
  end
end