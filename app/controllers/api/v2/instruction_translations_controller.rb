module Api
  module V2
    class InstructionTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if !params[:language].blank? && !params[:instruction_id].blank?
          instruction = Instruction.find(params[:instruction_id])
          respond_with instruction.instruction_translations.where(language: params[:language])
        elsif !params[:language].blank?
          respond_with InstructionTranslation.where(language: params[:language])
        else
          respond_with InstructionTranslation.all
        end
      end

      def create
        instruction_translation = InstructionTranslation.new(instruction_translations_params)
        if instruction_translation.save
          render json: instruction_translation, status: :created
        else
          render json: { errors: instruction_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        instruction_translation = InstructionTranslation.find params[:id]
        respond_with instruction_translation.update_attributes(instruction_translations_params)
      end

      def batch_update
        translations = []
        ActiveRecord::Base.transaction do
          params[:instruction_translations].each do |translation_params|
            if translation_params[:id]
              it = InstructionTranslation.find(translation_params[:id])
              translations << it if it.update_attributes(translation_params.permit(:instruction_id, :text, :language))
            elsif !translation_params[:text].blank?
              it = InstructionTranslation.new(translation_params.permit(:instruction_id, :text, :language))
              translations << it if it.save
            end
          end
        end
        render json: :translations, status: :ok
      end

      private

      def instruction_translations_params
        params.require(:instruction_translation).permit(:instruction_id, :text, :language)
      end
    end
  end
end
