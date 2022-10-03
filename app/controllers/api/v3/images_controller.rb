module Api
  module V3
    class ImagesController < Api::V1::ImagesController
      respond_to :json

      def index
        name = "#{params[:instrument_id]}.zip"
        zipped = Tempfile.new(name)
        Zip::File.open(zipped, Zip::File::CREATE) do |zipfile|
          imgs = Dir["#{Rails.root}/files/images/#{params[:instrument_id]}/*.png"]
          imgs.each do |img|
            filename = img.split('/').last
            zipfile.add(filename, File.new(img).path)
          end
        end
        send_file zipped, type: 'application/zip', filename: name
      end

      def show
        if params[:option_id]
          option = Option.find(params[:option_id])
          file_name = "#{Rails.root}/files/images/options/#{option.identifier}.png"
        elsif params[:question_id]
          iq = InstrumentQuestion.find(params[:question_id])
          file_name = "#{Rails.root}/files/images/questions/#{iq.question.question_identifier}.png"
        end
        if File.exist?(file_name)
          send_file file_name
        else
          render nothing: true, status: 404
        end
      end
    end
  end
end
