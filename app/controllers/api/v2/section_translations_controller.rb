module Api
  module V2
    class SectionTranslationsController < ApiApplicationController
      respond_to :json

      def index
        render json: :null unless current_user
        project = Project.find params[:project_id]
        instrument = project.instruments.find params[:instrument_id]
        respond_with instrument.section_translations
      end

      def batch_update
        translations = []
        ActiveRecord::Base.transaction do
          params[:section_translations].each do |translation_params|
            if translation_params[:id]
              st = SectionTranslation.find(translation_params[:id])
              translations << st if st.update_attributes(translation_params.permit(:section_id, :text, :language))
            elsif !translation_params[:text].blank?
              st = SectionTranslation.new(translation_params.permit(:section_id, :text, :language))
              translations << st if st.save
            end
          end
        end
        render json: :translations, status: :ok
      end

    end
  end
end
