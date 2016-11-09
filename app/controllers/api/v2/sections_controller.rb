module Api
  module V2
    class SectionsController < ApiApplicationController
      include Syncable

      def index
        project = Project.find(params[:project_id])
        sections = to_sync(project.sections, 'sections', params[:last_sync_time])
        render json: sections.includes(:translations)
      end

      def show
        project = Project.find(params[:project_id])
        render json: project.sections.find(params[:id])
      end
    end
  end
end