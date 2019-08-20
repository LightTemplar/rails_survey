# frozen_string_literal: true

module Api
  module V4
    class QuestionSetsController < Api::V4::ApiController
      respond_to :json

      def index
        @question_sets = QuestionSet.all.includes(folders: [:questions])
      end
    end
  end
end
