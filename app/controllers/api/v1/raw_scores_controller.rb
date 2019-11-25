# frozen_string_literal: true

module Api
  module V1
    class RawScoresController < ApiApplicationController
      respond_to :json

      def create
        @raw_score = RawScore.new(raw_score_params)
        if @raw_score.save
          render json: @raw_score, status: :created
        else
          render nothing: true, status: :unprocessable_entity
        end
      end

      private

      def raw_score_params
        params.require(:raw_score).permit(:uuid, :score_unit_id, :score_uuid, :value)
      end
    end
  end
end
