# frozen_string_literal: true

module Api
  module V4
    class SurveysController < Api::V4::ApiController
      respond_to :json

      def index
        instrument_ids = current_user.instruments.pluck(:id)
        @surveys = Survey.where(instrument_id: instrument_ids)
      end
    end
  end
end
