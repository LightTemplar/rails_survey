# frozen_string_literal: true

module Api
  module V2
    class QuestionsController < ApiApplicationController
      respond_to :json

      def index
        if !params[:instrument_id].blank?
          instrument = Instrument.find params[:instrument_id]
          respond_with instrument.questions
        else
          respond_with Question.all
        end
      end
    end
  end
end
