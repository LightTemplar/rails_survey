module Api
  module V1
    module Frontend
      class OptionScoresController < ApiApplicationController
        respond_to :json

        def index
          if current_user
            score_unit = current_project.score_units.find params[:score_unit_id]
            respond_with score_unit.option_scores
          end
        end

      end
    end
  end
end