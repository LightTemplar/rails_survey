require 'rake'

Rake::Task.clear
RailsSurvey::Application.load_tasks

module Api
  module V2
    class ProjectsController < ApiApplicationController
      respond_to :json

      def index
        respond_with current_user.projects
      end

      def show
        respond_with current_user.projects.find(params[:id])
      end

      def import_instrument
        project = Project.find params[:id]

        Rake::Task['import'].reenable
        Rake::Task['import'].invoke(params[:file].tempfile.path)

        if project
          render json: :ok, status: :created
        else
          render json: { errors: 'instrument import unsuccessfull' }, status: :unprocessable_entity
        end
      end
    end
  end
end
