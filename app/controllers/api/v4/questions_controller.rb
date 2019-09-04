# frozen_string_literal: true

module Api
  module V4
    class QuestionsController < Api::V4::ApiController
      respond_to :json

      def index
        @questions = Question.all
      end
    end
  end
end
