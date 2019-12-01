# frozen_string_literal: true

class Api::V4::ProjectsController < Api::V4::ApiController
  respond_to :json

  def index
    @projects = current_user.projects
  end

  def show
    @project = current_user.projects.find(params[:id])
  end
end
