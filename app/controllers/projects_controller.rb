# frozen_string_literal: true

class ProjectsController < ApplicationController
  def index
    @projects = current_user.projects
    authorize @projects
  end

  def show
    @project = current_user.projects.find(params[:id])
    authorize @project
    set_current_project @project
  end
end
