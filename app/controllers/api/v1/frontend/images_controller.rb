module Api
  module V1
    module Frontend
      class ImagesController < ApiApplicationController
        respond_to :json

        def index
          if current_user
            #respond_with current_project.instruments, include: :translations
          end
        end

        def show
          if current_user
            #respond_with current_project.instruments, include: :translations
          end
        end
        
      end
    end
  end
end