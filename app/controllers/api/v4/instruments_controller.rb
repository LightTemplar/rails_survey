# frozen_string_literal: true

module Api
  module V4
    class InstrumentsController < Api::V4::ApiController
      respond_to :json
      before_action :set_project, only: %i[show create update destroy reorder_sections]
      before_action :set_instrument, only: %i[update destroy reorder_sections]

      def index
        project_ids = current_user.projects.pluck(:id)
        @instruments = Instrument.where(project_id: project_ids).order('title')
      end

      def show
        @instrument = @project.instruments.includes(:sections, :displays).find(params[:id])
      end

      def create
        instrument = @project.instruments.new(instrument_params)
        if instrument.save
          render json: instrument, status: :created
        else
          render json: { errors: instrument.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        respond_with @instrument.update_attributes(instrument_params)
      end

      def destroy
        respond_with @instrument.destroy
      end

      def reorder_sections
        if @instrument.reorder_sections(params[:order])
          render json: :ok, status: :created
        else
          render json: { errors: 'sections reorder unsuccessful' }, status: :unprocessable_entity
        end
      end

      private

      def instrument_params
        params.require(:instrument).permit(:title, :language, :published, :project_id)
      end

      def set_project
        @project = current_user.projects.find(params[:project_id])
      end

      def set_instrument
        @instrument = @project.instruments.find(params[:id])
      end
    end
  end
end
