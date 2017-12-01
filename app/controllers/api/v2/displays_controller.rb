module Api
  module V2
    class DisplaysController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_project

      def index
        @displays = @instrument.displays.order(:position).includes(:instrument_questions)
      end

      # def show
      #   @instrument_question = @instrument.instrument_questions.find(params[:id])
      # end

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

      private

      def set_instrument_project
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
      end

      def display_params
        params.require(:display).permit(:instrument_id, :position, :mode)
      end
    end
  end
end
