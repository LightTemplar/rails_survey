module Api
  module V2
    class DisplaysController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_project

      def index
        @displays = @instrument.displays.order(:position).includes(:instrument_questions)
      end

      def show
        @display = @instrument.displays.includes(:instrument_questions).find(params[:id])
      end

      def create
        display = @instrument.displays.new(display_params)
        if display.save
          render json: display, status: :created
        else
          render json: { errors: display.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        display = @instrument.displays.find(params[:id])
        respond_with display.update_attributes(display_params)
      end

      def destroy
        display = @instrument.displays.find(params[:id])
        if display.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: display.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def copy
        display = @instrument.displays.find(params[:id])
        destination = @project.instruments.find(params[:destination_instrument_id])
        if destination && display.copy(destination, params[:display_type])
          render json: destination, status: :created
        else
          render json: { errors: 'display copy unsuccessfull' }, status: :unprocessable_entity
        end
      end

      def move
        display = @instrument.displays.find(params[:id])
        destination = display.move(params[:destination_display_id], params[:moved])
        if destination
          render json: destination, status: :ok
        else
          render json: { errors: 'question move unsuccessfull' }, status: :unprocessable_entity
        end
      end

      private

      def set_instrument_project
        @project = current_user.projects.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
      end

      def display_params
        params.require(:display).permit(:instrument_id, :position, :mode, :title)
      end
    end
  end
end
