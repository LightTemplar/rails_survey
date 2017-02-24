class RostersController < ApplicationController
  after_action :verify_authorized

  def index
    @rosters = current_project.rosters.order('created_at DESC')
    authorize @rosters
  end

  def show
    @roster = current_project.rosters.find(params[:id])
    authorize @roster
  end
end