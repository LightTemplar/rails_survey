# frozen_string_literal: true

module Api
  module V4
    class DisplaysController < Api::V4::ApiController
      respond_to :json
      before_action :set_instrument, only: %i[show create update destroy]
      before_action :set_display, only: %i[update destroy]

      def show
        @display = @instrument.displays.includes(instrument_questions: [question: [:instruction]]).find(params[:id])
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
        respond_with @display.update_attributes(display_params)
      end

      def destroy
        respond_with @display.destroy
      end

      private

      def display_params
        params.require(:display).permit(:title, :instrument_id, :position, :section_id)
      end

      def set_instrument
        project = current_user.projects.find(params[:project_id])
        @instrument = project.instruments.find(params[:instrument_id])
      end

      def set_display
        @display = @instrument.displays.find(params[:id])
      end
    end
  end
end
