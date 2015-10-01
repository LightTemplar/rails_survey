module Api
  module V1
    module Frontend
      class ImagesController < ApiApplicationController
        respond_to :json

        def index
          question = current_project.questions.find(params[:question_id])
          respond_with question.images.order('number')
        end

        def show
          @image = current_project.images.find(params[:id])
          send_file @image.photo.path(:medium), :type => @image.photo_content_type, :disposition => 'inline'
        end

        def create
          question = current_project.questions.find(params[:question_id])
          @image = question.images.new(image_params)
          if @image.save
            render nothing: true, status: :created
          else
            render nothing: true, status: :unprocessable_entity
          end
        end

        def update
          question = current_project.questions.find(params[:question_id])
          image = question.images.find(params[:id])
          if image.update_attributes(image_params)
            respond_with image
          else
            render nothing: true, status: :unprocessable_entity
          end
        end

        def destroy
          respond_with current_project.images.find(params[:id]).destroy
        end

        private
        def image_params
          params.permit(:photo, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :question_id, :description, :number)
        end

      end
    end
  end
end