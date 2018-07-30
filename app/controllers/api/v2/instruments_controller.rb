module Api
  module V2
    class InstrumentsController < ApiApplicationController
      respond_to :json

      def index
        project = current_user.projects.find params[:project_id]
        @instruments = project.instruments.order('title') if project
      end

      def show
        project = current_user.projects.find params[:project_id]
        @instrument = project.instruments.find(params[:id]) if project
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

      def copy
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find(params[:id])
        destination = current_user.projects.find(params[:destination_project_id])
        instrument_copy = instrument.copy(destination, params[:display_type]) if destination
        if destination && instrument_copy
          render json: instrument_copy, status: :created
        else
          render json: { errors: 'instrument copy unsuccessful' }, status: :unprocessable_entity
        end
      end

      def reorder
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find(params[:id])
        if instrument.reorder(params[:order])
          render json: :ok, status: :created
        else
          render json: { errors: 'question reorder unsuccessful' }, status: :unprocessable_entity
        end
      end

      def reorder_displays
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find(params[:id])
        if instrument.reorder_displays(params[:display_ids])
          render json: :ok, status: :created
        else
          render json: { errors: 'question reorder unsuccessful' }, status: :unprocessable_entity
        end
      end

      def set_skip_patterns
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find(params[:id])
        if instrument.set_skip_patterns
          render json: :ok, status: :created
        else
          render json: { errors: 'skip patterns import unsuccessful' }, status: :unprocessable_entity
        end
      end

      private

      def instrument_params
        params.require(:instrument).permit(:title, :language, :published, :project_id, :display_ids)
      end

    end
  end
end
