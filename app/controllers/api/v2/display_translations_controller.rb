module Api
  module V2
    class DisplayTranslationsController < ApiApplicationController
      respond_to :json

      def index
        render json: :null unless current_user
        project = Project.find params[:project_id]
        instrument = project.instruments.find params[:instrument_id]
        respond_with instrument.display_translations
      end

      def batch_update
        translations = []
        ActiveRecord::Base.transaction do
          params[:display_translations].each do |translation_params|
            if translation_params[:id]
              translation = DisplayTranslation.find(translation_params[:id])
              translations << translation if translation.update_attributes(translation_params.permit(:display_id, :text, :language))
            elsif !translation_params[:text].blank?
              translation = DisplayTranslation.new(translation_params.permit(:display_id, :text, :language))
              translations << translation if translation.save
            end
          end
        end
        render json: :translations, status: :ok
      end

    end
  end
end
