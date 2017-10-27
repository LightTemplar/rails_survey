class InstrumentQuestionSetsController < ApplicationController

  def index
    @project = current_project
    @instrument = current_project.instruments.find(params[:instrument_id])
  end

end
