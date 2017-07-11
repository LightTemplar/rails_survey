class RandomizedFactorsController < ApplicationController
  def index
    @instrument = current_project.instruments.find(params[:instrument_id])
  end
end
