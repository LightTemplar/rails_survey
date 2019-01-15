module Api
  module V2
    class InstrumentTranslationsController < ApiApplicationController
      respond_to :json

      def index
        render json: :null unless current_user
        project = Project.find params[:project_id]
        instrument = project.instruments.find params[:instrument_id]
        respond_with instrument.translations
      end

      def show
        render json: :null unless current_user
        project = Project.find params[:project_id]
        instrument = project.instruments.find params[:instrument_id]
        respond_with instrument.translations.find(params[:id])
      end

      def create
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find params[:instrument_id]
        instrument_translation = instrument.translations.new(instrument_translation_params)
        if instrument_translation.save
          render json: instrument_translation, status: :created
        else
          render json: { errors: instrument_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find params[:instrument_id]
        instrument_translation = instrument.translations.find(params[:id])
        respond_with instrument_translation.update_attributes(instrument_translations_params)
      end

      def destroy
        project = current_user.projects.find(params[:project_id])
        instrument = project.instruments.find params[:instrument_id]
        instrument_translation = instrument.translations.find(params[:id])
        respond_with instrument_translation.destroy
      end

      private

      def instrument_translation_params
        params.require(:instrument_translation).permit(:title, :language, :active, :instrument_id)
      end

    end
  end
end
