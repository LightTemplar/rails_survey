module Api
  module V2
    class OptionSetsController < ApiApplicationController
      respond_to :json

      def index
        respond_with OptionSet.all
      end
    end
  end
end
