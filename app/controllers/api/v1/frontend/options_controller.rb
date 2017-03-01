module Api
  module V1
    module Frontend
      class OptionsController < ApiApplicationController
        respond_to :json

        def create
          question = current_project.questions.find(params[:question_id])
          @option = question.options.new(option_params)
          authorize @option
          if @option.save
            render json: @option, status: :created
          else
            render nothing: true, status: :unprocessable_entity
          end
        end

        def update
          option = current_project.options.find(params[:id])
          authorize option
          respond_with option.update_attributes(option_params)
        end

        def destroy
          option = current_project.options.find(params[:id])
          authorize option
          respond_with option.destroy
        end

        private

        def option_params
          params.require(:option).permit(:question_id, :text, :next_question, :number_in_question, :instrument_version_number, :critical)
        end
      end
    end
  end
end
