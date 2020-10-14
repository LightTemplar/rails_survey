# frozen_string_literal: true

module Api
  module V2
    class InstrumentsController < Api::V2::ApiController
      respond_to :json

      def index
        @instruments = current_device_user.published_instruments
      end

      def show
        @instrument = current_device_user.published_instruments
                                         .includes(:instrument_questions)
                                         .find(params[:id])
      end
    end
  end
end
