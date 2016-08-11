module Api
  module V1
    module Frontend
      class ScoreUnitsController < ApiApplicationController
        respond_to :json

        def index
          if current_user
            score_scheme = current_project.score_schemes.find params[:score_scheme_id]
            respond_with score_scheme.score_units.order('id ASC')
          end
        end

        def show
          if current_user
            current_scheme = current_project.score_schemes.find params[:score_scheme_id]
            respond_with current_scheme.score_units.find params[:id]
          end
        end

        def create
          score_scheme = current_project.score_schemes.find params[:score_scheme_id]
          score_unit = score_scheme.score_units.new(score_unit_params)
          instrument = current_project.instruments.find params[:instrument_id]
          questions = instrument.questions.where(id: params[:question_ids])
          score_unit.questions << questions
          if score_unit.save
            params[:option_scores].each do |opt|
              OptionScore.create(score_unit_id: score_unit.id, option_id: opt['option_id'], value: opt['score'])
            end
            render json: score_unit, status: :created
          else
            render json: {errors: score_unit.errors.full_messages}, status: :unprocessable_entity
          end
        end

        def questions
          if current_user
            score_scheme = current_project.score_schemes.find params[:score_scheme_id]
            score_unit = score_scheme.score_units.find params[:id]
            respond_with score_unit.questions
          end
        end

        def options
          if current_user
            score_scheme = current_project.score_schemes.find params[:score_scheme_id]
            respond_with score_scheme.instrument.options.where(question_id: params[:question_ids]).where(special: false)
          end
        end

        private
        def score_unit_params
          params.require(:score_unit).permit(:score_scheme_id, :question_type, :min, :max, :weight, question_ids: [],
            option_scores: [])
        end

      end
    end
  end
end
