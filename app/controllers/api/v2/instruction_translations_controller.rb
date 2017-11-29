module Api
  module V2
    class InstructionTranslationsController < ApiApplicationController
      respond_to :json

      def index
        if params[:language]
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

      private

      def instruction_translations_params
        params.require(:instruction_translation).permit(:instruction_id, :text, :language)
      end
    end
  end
end
