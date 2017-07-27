class ReorderQuestionsController < ApplicationController
  after_action :verify_authorized

  def index
    @instrument = current_project.instruments.includes(:questions).find(params[:instrument_id])
    authorize @instrument
  end

  def reorder
    instrument = current_project.instruments.includes(:questions).find params[:instrument_id]
    authorize instrument
    MassQuestionsReorderWorker.perform_async(instrument.id, params[:reorder])
    redirect_to project_instrument_path(current_project.id, instrument.id)
  end
end
