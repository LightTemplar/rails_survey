# frozen_string_literal: true

module Api
  module V2
    class ProjectsController < ApiApplicationController
      respond_to :json

      def index
        @projects = current_user.projects
      end

      def show
        @project = current_user.projects.find(params[:id])
      end

      def import_instrument
        project = Project.find params[:id]
        file = Tempfile.new('instrument_csv', 'tmp')
        File.open(file.path, 'w:ASCII-8BIT') do |file|
          file << params[:file].read
        end
        RakeTaskWorker.perform_async('import', file.path)
        if project
          render json: :ok, status: :created
        else
          render json: { errors: 'instrument import unsuccessfull' }, status: :unprocessable_entity
        end
      end

      def v1_v2_import
        file = Tempfile.new('v1_v2_csv', 'tmp')
        File.open(file.path, 'w:ASCII-8BIT') do |file|
          file << params[:file].read
        end
        RakeTaskWorker.perform_async('v1_v2_import', file.path)
        render json: :ok, status: :created
      end
    end
  end
end
