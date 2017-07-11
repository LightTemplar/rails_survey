module Api
  module V1
    module Frontend
      class GridLabelsController < ApiApplicationController
        respond_to :json

        def index
          instrument = current_project.instruments.find(params[:instrument_id])
          grid = instrument.grids.find(params[:grid_id])
          respond_with grid.grid_labels
        end

        def show
          instrument = current_project.instruments.find(params[:instrument_id])
          grid = instrument.grids.find(params[:grid_id])
          grid_label = grid.grid_labels.find(params[:id])
          respond_with grid_label
        end

        def create
          instrument = current_project.instruments.find(params[:instrument_id])
          grid = instrument.grids.find(params[:grid_id])
          grid_label = grid.grid_labels.new(grid_label_params)
          if grid_label.save
            render json: grid_label, status: :created
          else
            render json: { errors: grid_label.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          instrument = current_project.instruments.find(params[:instrument_id])
          grid = instrument.grids.find(params[:grid_id])
          grid_label = grid.grid_labels.find(params[:id])
          grid_label.update_attributes(grid_label_params)
          respond_with grid_label
        end

        def destroy
          instrument = current_project.instruments.find(params[:instrument_id])
          grid = instrument.grids.find(params[:grid_id])
          grid_label = grid.grid_labels.find(params[:id])
          respond_with grid_label.destroy
        end

        private

        def grid_label_params
          params.require(:grid_label).permit(:label, :grid_id, :position)
        end
      end
    end
  end
end
