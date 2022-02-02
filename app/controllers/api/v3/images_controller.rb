module Api
  module V3
    class ImagesController < Api::V1::ImagesController
      respond_to :json

      def show
        option = Option.find(params[:id])
        file_name = "#{Rails.root}/files/images/#{option.identifier}.png"
        if File.exist?(file_name)
          send_file file_name
        else
          render nothing: true, status: 404
        end
      end
    end
  end
end
