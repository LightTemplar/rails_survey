module Api
  module V1
    class InstrumentsController < ApplicationController
      respond_to :json

      def index
        respond_with Instrument.all
      end

      def show
        respond_with Instrument.find(params[:id])
      end
    end
  end
end
