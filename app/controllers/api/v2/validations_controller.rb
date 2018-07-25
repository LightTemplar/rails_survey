module Api
  module V2
    class ValidationsController < ApiApplicationController
      respond_to :json

      def index
        @validations = Validation.all.order(updated_at: :desc)
      end

      def show
        @validation = Validation.find(params[:id])
      end

      def create
        validation = Validation.new(validation_params)
        if validation.save
          render json: validation, status: :created
        else
          render json: { errors: validation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        validation = Validation.find(params[:id])
        respond_with validation.update_attributes(validation_params)
      end

      def destroy
        validation = Validation.find(params[:id])
        respond_with validation.destroy
      end

      private

      def validation_params
        params.require(:validation).permit(:title, :validation_text, :validation_message, :validation_type,
                                           :response_identifier, :relational_operator)
      end
    end
  end
end
