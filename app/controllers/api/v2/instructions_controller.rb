module Api
  module V2
    class InstructionsController < ApiApplicationController
      respond_to :json

      def index
        respond_with Instruction.all.order(updated_at: :desc)
      end

      def show
        respond_with Instruction.find(params[:id])
      end

      def create
        instruction = Instruction.new(instruction_params)
        if instruction.save
          render json: instruction, status: :created
        else
          render json: { errors: instruction.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        instruction = Instruction.find(params[:id])
        respond_with instruction.update_attributes(instruction_params)
      end

      def destroy
        instruction = Instruction.find(params[:id])
        respond_with instruction.destroy
      end

      private

      def instruction_params
        params.require(:instruction).permit(:title, :text)
      end
    end
  end
end
