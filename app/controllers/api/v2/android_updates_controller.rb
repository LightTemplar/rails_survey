module Api
  module V2
    class AndroidUpdatesController < ApiApplicationController

      def index
        render json: AndroidUpdate.latest_version
      end   
      
      def show
        @apk = AndroidUpdate.find(params[:id])
        send_file @apk.apk_update.path
      end
        
    end  
  end
end