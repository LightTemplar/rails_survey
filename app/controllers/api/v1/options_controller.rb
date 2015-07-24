module Api
  module V1
    class OptionsController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        options = to_sync(project.options, 'options', params[:last_sync_time])
        respond_with options, include: :translations
      end

      def show
        respond_with Option.find(params[:id])
      end
    end
  end
end
