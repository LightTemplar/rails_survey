module Api
  module V1
    module Frontend
      class RandomizedOptionsController < ApiApplicationController
        respond_to :json

        def create
          instrument = current_project.instruments.find(params[:instrument_id])
          @option = instrument.randomized_options.new(option_params)
          authorize @option
          if @option.save
            render json: @option, status: :created
          else
            render nothing: true, status: :unprocessable_entity
          end
        end

        def update
          option = current_project.randomized_options.find(params[:id])
          authorize option
          respond_with option.update_attributes(option_params)
        end

        def destroy
          option = current_project.randomized_options.find(params[:id])
          authorize option
          respond_with option.destroy
        end

        private

        def option_params
          params.require(:randomized_option).permit(:randomized_factor_id, :text)
        end
      end
    end
  end
end
