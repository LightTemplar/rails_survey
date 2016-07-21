class ScoreSchemesController < ApplicationController

  def index
    @schemes = current_project.score_schemes
  end

  def show
    @scheme = current_project.score_schemes.find params[:id]
  end

end