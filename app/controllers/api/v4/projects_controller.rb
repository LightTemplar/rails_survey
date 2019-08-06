# frozen_string_literal: true

module Api
  module V4
    class ProjectsController < Api::V4::ApiController
      respond_to :json

      def index
        @projects = current_user.projects
      end

      def show
        @project = current_user.projects.find(params[:id])
      end
    end
  end
end
