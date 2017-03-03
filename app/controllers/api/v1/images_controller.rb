module Api
  module V1
    class ImagesController < ApiApplicationController
      include Syncable
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @images = to_sync(project.images, 'images', params[:last_sync_time])
      end

      def show
        project = Project.find(params[:project_id])
        image = project.images.where(id: params[:id]).try(:first)
        if image
          send_file image.photo.path
        else
          render nothing: true, status: 404
        end
      end
    end
  end
end
