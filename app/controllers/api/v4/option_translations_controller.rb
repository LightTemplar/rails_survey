# frozen_string_literal: true

module Api
  module V4
    class OptionTranslationsController < Api::V4::ApiController
      respond_to :json
      before_action :set_option_translation, only: %i[update destroy]

      def index
        @option_translations = OptionTranslation.where(language: params[:language])
      end

      def create
        option_translation = OptionTranslation.new(option_translations_params)
        if option_translation.save
          render json: option_translation, status: :created
        else
          render json: { errors: option_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        respond_with @option_translation.update_attributes(option_translations_params)
      end

      def destroy
        respond_with @option_translation.destroy
      end

      private

      def set_option_translation
        @option_translation = OptionTranslation.find params[:id]
      end

      def option_translations_params
        params.require(:option_translation).permit(:option_id, :text, :language)
      end
    end
  end
end
