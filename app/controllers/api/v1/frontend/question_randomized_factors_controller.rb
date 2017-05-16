module Api
  module V1
    module Frontend
      class QuestionRandomizedFactorsController < ApiApplicationController
        respond_to :json

        def create
          question = current_project.questions.find(params[:question_id])
          @question_randomized_factor = question.question_randomized_factors.new(question_randomized_factor_params)
          authorize @question_randomized_factor
          if @question_randomized_factor.save
            render json: @question_randomized_factor, status: :created
          else
            render nothing: true, status: :unprocessable_entity
          end
        end

        def update
          question_randomized_factor = current_project.question_randomized_factors.find(params[:id])
          authorize question_randomized_factor
          respond_with question_randomized_factor.update_attributes(question_randomized_factor_params)
        end

        def destroy
          question_randomized_factor = current_project.question_randomized_factors.find(params[:id])
          authorize question_randomized_factor
          respond_with question_randomized_factor.destroy
        end

        private

        def question_randomized_factor_params
          params.require(:question_randomized_factor).permit(:question_id, :position, :randomized_factor_id)
        end
      end
    end
  end
end
