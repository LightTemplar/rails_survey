class SurveysController < ApplicationController
  after_action :verify_authorized

  def index
    @instruments = current_project.instruments
    @aggregators = current_project.aggregators
    @surveys = current_project.surveys.order(created_at: :desc).page(params[:page])
    authorize @surveys
  end

  def show
    @survey = current_project.surveys.find(params[:id])
    authorize @survey
    @instrument_version = @survey.instrument_version
  end

  def instrument_surveys
    instrument = current_project.instruments.find params[:instrument_id]
    @surveys = instrument.surveys.order(created_at: :desc).page(params[:page])
    authorize @surveys
  end

  def identifier_surveys
    survey = current_project.surveys.find(params[:id])
    @surveys = current_project.surveys_by_aggregator(survey).order(created_at: :desc).page(params[:page])
    authorize @surveys
  end
end
