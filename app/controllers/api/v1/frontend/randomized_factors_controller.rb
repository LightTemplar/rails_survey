module Api
  module V1
    module Frontend
      class RandomizedFactorsController < ApiApplicationController
        respond_to :json

        def create
          instrument = current_project.instruments.find(params[:instrument_id])
          @randomized_factor = instrument.randomized_factors.new(randomized_factor_params)
          authorize @randomized_factor
          if @randomized_factor.save
            render json: @randomized_factor, status: :created
          else
            render nothing: true, status: :unprocessable_entity
          end
        end

        def update
          randomized_factor = current_project.randomized_factors.find(params[:id])
          authorize randomized_factor
          respond_with randomized_factor.update_attributes(randomized_factor_params)
        end

        def destroy
          randomized_factor = current_project.randomized_factors.find(params[:id])
          authorize randomized_factor
          respond_with randomized_factor.destroy
        end

        private

        def randomized_factor_params
          params.require(:randomized_factor).permit(:instrument_id, :title)
        end
      end
    end
  end
end
