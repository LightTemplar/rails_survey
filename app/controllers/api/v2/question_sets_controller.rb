module Api
  module V2
    class QuestionSetsController < ApiApplicationController
      respond_to :json

      def index
        respond_with QuestionSet.all
      end
    end
  end
end
