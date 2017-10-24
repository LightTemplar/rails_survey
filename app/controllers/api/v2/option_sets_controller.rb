module Api
  module V2
    class OptionSetsController < ApiApplicationController
      respond_to :json
      before_action :set_option_set, only: [:update]

      def index
        respond_with OptionSet.all
      end

      def create
        option_set = OptionSet.new(option_set_params)
        if option_set.save
          render json: option_set, status: :created
        else
          render json: { errors: option_set.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        respond_with @option_set.update_attributes(option_set_params)
      end

      private

      def set_option_set
        @option_set = OptionSet.find(params[:id])
      end

      def option_set_params
        params.require(:option_set).permit(:title)
      end

    end
  end
end
