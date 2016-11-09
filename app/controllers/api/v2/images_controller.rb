module Api
  module V2
    class ImagesController < ApiApplicationController

      def index
        project = Project.find(params[:project_id])
        render json: project.images
      end   
      
      def show
        @image = Image.find(params[:id])
        send_file @image.photo.path
      end
        
    end  
  end
end