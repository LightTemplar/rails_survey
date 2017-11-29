module Api
  module V2
    class QuestionsController < ApiApplicationController
      respond_to :json
      
      def index
        respond_with Question.all
      end
    end
  end
end
