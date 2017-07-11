module Api
  module V1
    module Frontend
      class OptionScoresController < ApiApplicationController
        respond_to :json

        def index
          if current_user
            score_unit = current_project.score_units.find params[:score_unit_id]
            @option_scores = score_unit.option_scores
          end
        end

        def destroy
          if current_user
            unit = current_project.score_units.find params[:score_unit_id]
            option = unit.option_scores.find params[:id]
            if option.destroy
              render nothing: true, status: :ok
            else
              render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
