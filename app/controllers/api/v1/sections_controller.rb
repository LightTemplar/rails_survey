module Api
  module V1
    class SectionsController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @sections = to_sync(project.sections, 'sections', params[:last_sync_time])
      end

      def show
        project = Project.find(params[:project_id])
        @section = project.sections.find(params[:id])
      end
    end
  end
end
