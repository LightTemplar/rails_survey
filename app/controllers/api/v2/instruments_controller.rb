# frozen_string_literal: true

module Api
  module V2
    class InstrumentsController < Api::V2::ApiController
      respond_to :json

      def index
        @instruments = current_device_user.published_instruments
      end
    end
  end
end
