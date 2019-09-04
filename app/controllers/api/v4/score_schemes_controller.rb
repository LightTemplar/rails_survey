# frozen_string_literal: true

module Api
  module V4
    class ScoreSchemesController < Api::V4::ApiController
      respond_to :json
      before_action :set_instrument, only: %i[index show create update destroy]
      before_action :set_score_scheme, only: %i[update destroy]

      def index
        @score_schemes = @instrument.score_schemes
      end

      def show
        @score_scheme = @instrument.score_schemes.find(params[:id])
      end

      def create
        score_scheme = @instrument.score_schemes.new(score_scheme_params)
        if score_scheme.save
          render json: score_scheme, status: :created
        else
          render json: { errors: score_scheme.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        respond_with @score_scheme.update_attributes(score_scheme_params)
      end

      def destroy
        respond_with @score_scheme.destroy
      end

      private

      def score_scheme_params
        params.require(:score_scheme).permit(:title, :instrument_id, :active)
      end

      def set_instrument
        project = current_user.projects.find(params[:project_id])
        @instrument = project.instruments.find(params[:instrument_id])
      end

      def set_score_scheme
        @score_scheme = @instrument.score_schemes.find(params[:id])
      end
    end
  end
end
