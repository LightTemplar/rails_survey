module Api
  module V2
    class OptionSetsController < ApiApplicationController
      respond_to :json
      before_action :set_option_set, only: %i[update show destroy copy]

      def index
        respond_with OptionSet.all.order(:created_at)
      end

      def show
      end

      def create
        option_set = OptionSet.new(option_set_params)
        if option_set.save
          render json: option_set, status: :created
        else
          render json: {errors: option_set.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def update
        respond_with @option_set.update_attributes(option_set_params)
      end

      def destroy
        respond_with @option_set.destroy
      end

      def copy
        respond_with @option_set.copy
      end

      private

      def set_option_set
        @option_set = OptionSet.find(params[:id])
      end

      def option_set_params
        params.require(:option_sets).permit(:title, :special, :instruction_id)
      end

    end
  end
end
