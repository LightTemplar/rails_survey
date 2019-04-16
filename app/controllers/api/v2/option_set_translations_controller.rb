# frozen_string_literal: true

module Api
  module V2
    class OptionSetTranslationsController < ApiApplicationController
      respond_to :json
      before_action :set_option_set, only: %i[index create update destroy]

      def index
        respond_with @option_set.option_set_translations
      end

      def create
        option_set_translation = @option_set.option_set_translations.new(option_set_translation_params)
        if option_set_translation.save
          render json: option_set_translation, status: :created
        else
          render json: { errors: option_set_translation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        option_set_translation = @option_set.option_set_translations.find(params[:id])
        respond_with option_set_translation.update_attributes(option_set_translation_params)
      end

      def destroy
        option_set_translation = @option_set.option_set_translations.find(params[:id])
        respond_with option_set_translation.destroy
      end

      private

      def set_option_set
        @option_set = OptionSet.find(params[:option_set_id])
      end

      def option_set_translation_params
        params.require(:option_set_translation).permit(:option_set_id, :option_translation_id)
      end
    end
  end
end
