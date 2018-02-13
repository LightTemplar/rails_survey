module Api
  module V2
    class OptionsController < ApiApplicationController
      respond_to :json

      def index
        respond_with Option.all
      end
    end
  end
end
