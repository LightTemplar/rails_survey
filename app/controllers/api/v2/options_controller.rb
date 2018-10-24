module Api
  module V2
    class OptionsController < ApiApplicationController
      respond_to :json

      def index
        if !params[:instrument_id].blank?
          instrument = Instrument.find(params[:instrument_id])
          @options = instrument.options
        else
          @options = Option.all.order(updated_at: :desc)
        end
      end

      def create
        option = Option.new(option_params)
        if option.save
          render json: option, status: :created
        else
          render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        option = Option.find(params[:id])
        respond_with option.update_attributes(option_params)
      end

      def destroy
        option = Option.find(params[:id])
        respond_with option.destroy
      end

      private
      def option_params
        params.require(:option).permit(:text, :identifier)
      end
    end
  end
end
