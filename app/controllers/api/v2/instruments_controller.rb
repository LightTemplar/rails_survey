module Api
  module V2
    class InstrumentsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find params[:project_id]
        @instruments = project.instruments.order('title') if current_user && project
      end

      def show
        project = Project.find params[:project_id]
        respond_with project.instruments.find(params[:id]) if current_user && project
      end

      def create
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.new(instrument_params)
        if instrument.save
          render json: instrument, status: :created
        else
          render json: { errors: instrument.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find(params[:id])
        respond_with instrument.update_attributes(instrument_params)
      end

      def destroy
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find(params[:id])
        respond_with instrument.destroy
      end

      private

      def instrument_params
        params.require(:instrument).permit(:title, :language, :published, :project_id)
      end

    end
  end
end
