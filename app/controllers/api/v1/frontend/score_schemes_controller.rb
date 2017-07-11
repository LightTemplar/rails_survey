module Api
  module V1
    module Frontend
      class ScoreSchemesController < ApiApplicationController
        respond_to :json

        def index
          @score_schemes = current_project.score_schemes.order(updated_at: :desc) if current_user
        end

        def show
          @score_scheme = current_project.score_schemes.find params[:id] if current_user
        end

        def create
          instrument = current_project.instruments.find(params[:instrument_id])
          scheme = instrument.score_schemes.new(score_scheme_params)
          if scheme.save
            render json: scheme, status: :created
          else
            render json: { errors: scheme.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def score_scheme_params
          params.require(:score_scheme).permit(:instrument_id, :title)
        end
      end
    end
  end
end
