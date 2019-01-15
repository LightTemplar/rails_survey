module Api
  module V2
    class SectionsController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_project

      def index
        @sections = @instrument.sections
      end

      def show
        @section = @instrument.sections.includes(:instrument_questions).find(params[:id])
      end

      def create
        section = @instrument.sections.new(section_params)
        if section.save
          render json: section, status: :created
        else
          render json: { errors: section.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        section = @instrument.sections.find(params[:id])
        respond_with section.update_attributes(section_params)
      end

      def destroy
        section = @instrument.sections.find(params[:id])
        if section.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: section.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_instrument_project
        @project = current_user.projects.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
      end

      def section_params
        params.require(:section).permit(:instrument_id, :title)
      end
    end
  end
end
