module Api
  module V1
    class ScoresController < ApiApplicationController
      protect_from_forgery with: :null_session
      respond_to :json

      def create
        @score = Score.new(score_params)
        if @score.save
          render json: @score, status: :created
        else
          render nothing: true, status: :unprocessable_entity
        end
      end

      private

      def score_params
        params.require(:score).permit(:uuid, :survey_uuid, :score_scheme_id, :score_sum, :device_uuid, :device_label)
      end
    end
  end
end
