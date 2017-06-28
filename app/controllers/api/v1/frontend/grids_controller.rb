module Api
  module V1
    module Frontend
      class GridsController < ApiApplicationController
        respond_to :json

        def index
          instrument = current_project.instruments.find(params[:instrument_id])
          @grids = instrument.grids
        end

        def show
          instrument = current_project.instruments.find(params[:instrument_id])
          @grid = instrument.grids.find params[:id]
        end

        def create
          instrument = current_project.instruments.find(params[:instrument_id])
          grid = instrument.grids.new(grid_params)
          if grid.save
            render json: grid, status: :created
          else
            render json: { errors: grid.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          instrument = current_project.instruments.find(params[:instrument_id])
          grid = instrument.grids.find(params[:id])
          grid.update_attributes(grid_params)
          respond_with grid
        end

        def destroy
          instrument = current_project.instruments.find(params[:instrument_id])
          grid = instrument.grids.find(params[:id])
          respond_with grid.destroy
        end

        private

        def grid_params
          params.require(:grid).permit(:instrument_id, :question_type, :name, :instructions)
        end
      end
    end
  end
end
